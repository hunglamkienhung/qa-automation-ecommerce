"""The FE branch for the mini-shop storefront. Binds ../../features/fe-minishop.feature.
Mirror of node/fe/ui/steps/minishop.steps.js. The `page` fixture is
pytest-playwright's; the comparison figures come from the store (opened by the
shared @minishop steps) and the API.
"""

from __future__ import annotations

import re

from pytest_bdd import given, parsers, scenarios, then, when

from be.api.venues.minishop import ApiUnreachable, MiniShop
from fe.ui.pages.minishop import MiniShopPage, ScreenNotReady

scenarios("fe-minishop.feature")

shop = MiniShop()
UNREACHABLE = (ScreenNotReady, ApiUnreachable)


def money(c):
    return "$" + f"{c / 100:.2f}"


@given("the storefront is open")
def storefront_open(page, qa):
    page.set_viewport_size({"width": 1440, "height": 900})
    qa.mshop = MiniShopPage(page)

    def go():
        qa.mshop.open("/")
        qa.screen["catalogue"] = qa.mshop.catalogue()
    qa.fetch_or_block(UNREACHABLE, go)


def screen(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    try:
        passed, detail = fn()
    except UNREACHABLE as err:
        qa.unobservable(description, str(err))
        return
    qa.check(description, passed, detail)


def active_rows(qa):
    return qa.store.all("SELECT * FROM products WHERE active = 1 ORDER BY id")


def cat(qa):
    return qa.screen["catalogue"]


# ---------------------------------------------------------------- navigation


@when(parsers.parse("the product page for {pid:d} is opened"))
def open_product(page, qa, pid):
    def go():
        qa.mshop.open("/product/" + str(pid))
        try:
            qa.screen["product"] = qa.mshop.product()
        except ScreenNotReady:
            qa.screen["product"] = None
    qa.fetch_or_block(UNREACHABLE, go)


def place_order(qa, lines, coupon=None):
    if qa.source_error:
        return
    try:
        buyer = shop.register()
        cart = shop.open_cart()
        for qty, pid in lines:
            shop.add_item(cart, pid, qty)
        body = {"cart_token": cart}
        if coupon:
            body["coupon"] = coupon
        r = shop.checkout(buyer["token"], body)
        qa.noted = getattr(qa, "noted", {}) or {}
        qa.noted["order"] = r["body"]
    except ApiUnreachable as err:
        qa.source_error = str(err)


@given(parsers.parse("a placed order of {qty:d} of product {pid:d}"))
def placed_order(qa, qty, pid):
    place_order(qa, [(qty, pid)])


@given(parsers.parse("a placed order of {q1:d} of product {p1:d} and {q2:d} of product {p2:d}"))
def placed_order2(qa, q1, p1, q2, p2):
    place_order(qa, [(q1, p1), (q2, p2)])


@given(parsers.parse('a placed order of {qty:d} of product {pid:d} with coupon "{code}"'))
def placed_order_coupon(qa, qty, pid, code):
    place_order(qa, [(qty, pid)], code)


@when("the order page is opened")
def open_order(page, qa):
    def go():
        qa.mshop.open("/order/" + str(qa.noted["order"]["id"]))
        try:
            qa.screen["order"] = qa.mshop.order()
        except ScreenNotReady:
            qa.screen["order"] = None
    qa.fetch_or_block(UNREACHABLE, go)


@when(parsers.parse("the order page for {oid:d} is opened"))
def open_order_id(page, qa, oid):
    def go():
        qa.mshop.open("/order/" + str(oid))
        try:
            qa.screen["order"] = qa.mshop.order()
        except ScreenNotReady:
            qa.screen["order"] = None
    qa.fetch_or_block(UNREACHABLE, go)


# ---------------------------------------------------------------- catalogue Thens


@then("the catalogue lists the active products, once each")
def catalogue_active(qa):
    def ev():
        ids = sorted(r["id"] for r in cat(qa))
        want = [r["id"] for r in active_rows(qa)]
        return (ids == want, f"screen {len(ids)}, active {len(want)}")
    screen(qa, "catalogue == active products", ev)


@then("every catalogue price on screen equals the product row")
def catalogue_prices(qa):
    def ev():
        bad = [r for r in cat(qa) if r["priceText"] != money(qa.store.get("SELECT price_cents FROM products WHERE id = ?", r["id"])["price_cents"])]
        return (not bad, f"{len(cat(qa))} prices match" if not bad else "mismatch")
    screen(qa, "catalogue prices == rows", ev)


@then("every catalogue name on screen equals the product row")
def catalogue_names(qa):
    def ev():
        bad = [r for r in cat(qa) if r["name"] != qa.store.get("SELECT name FROM products WHERE id = ?", r["id"])["name"]]
        return (not bad, "names match" if not bad else "mismatch")
    screen(qa, "catalogue names == rows", ev)


@then(parsers.parse("product {pid:d} is shown out of stock"))
def product_out_of_stock(qa, pid):
    def ev():
        r = next((x for x in cat(qa) if x["id"] == pid), None)
        return (bool(r) and re.search(r"out of stock", r["stockText"], re.I) is not None, r["stockText"] if r else "not on catalogue")
    screen(qa, f"product {pid} out of stock", ev)


@then(parsers.parse("product {pid:d} is shown in stock"))
def product_in_stock(qa, pid):
    def ev():
        r = next((x for x in cat(qa) if x["id"] == pid), None)
        return (bool(r) and re.search(r"in stock", r["stockText"], re.I) is not None, r["stockText"] if r else "not on catalogue")
    screen(qa, f"product {pid} in stock", ev)


@then(parsers.parse("the catalogue does not list product {pid:d}"))
def catalogue_excludes(qa, pid):
    screen(qa, f"catalogue excludes {pid}", lambda: (not any(r["id"] == pid for r in cat(qa)), "ids " + ",".join(str(r["id"]) for r in cat(qa))))


@then("every catalogue price is shown as a dollar amount")
def prices_dollar(qa):
    screen(qa, "prices are dollar amounts", lambda: ((lambda bad: (not bad, "all dollar amounts" if not bad else ",".join(r["priceText"] for r in bad)))([r for r in cat(qa) if not re.match(r"^\$\d+\.\d{2}$", r["priceText"])])))


@then("the catalogue shows at least one product")
def catalogue_non_empty(qa):
    screen(qa, "catalogue non-empty", lambda: (len(cat(qa)) > 0, f"{len(cat(qa))} products"))


@then(parsers.parse("the catalogue price for product {pid:d} equals its row"))
def catalogue_price_pid(qa, pid):
    def ev():
        r = next((x for x in cat(qa) if x["id"] == pid), None)
        row = qa.store.get("SELECT price_cents FROM products WHERE id = ?", pid)
        return (bool(r) and r["priceText"] == money(row["price_cents"]), (r["priceText"] + " vs " + money(row["price_cents"])) if r else "not on catalogue")
    screen(qa, f"catalogue price {pid}", ev)


@then("the catalogue count equals the API active product count")
def catalogue_count_api(qa):
    def ev():
        r = shop.get("/products?limit=100")
        return (len(cat(qa)) == r["body"]["total"], f"screen {len(cat(qa))}, api {r['body']['total']}")
    screen(qa, "catalogue count == API active count", ev)


@then("each catalogue row links to its product page")
def rows_link(qa):
    def ev():
        links = qa.mshop.page.eval_on_selector_all("ul.catalogue li.product a", "els => els.map(e => e.getAttribute('href'))")
        bad = [h for h in links if not re.match(r"^/product/\d+$", h or "")]
        return (not bad and len(links) > 0, f"{len(links)} links" if not bad else ",".join(bad))
    screen(qa, "rows link to product pages", ev)


@then("every catalogue stock label is in stock or out of stock")
def stock_labels_known(qa):
    screen(qa, "stock labels known", lambda: ((lambda bad: (not bad, "all known" if not bad else ",".join(r["stockText"] for r in bad)))([r for r in cat(qa) if not re.match(r"^(in stock|out of stock)$", r["stockText"], re.I)])))


@then("no catalogue product id appears twice")
def ids_unique(qa):
    def ev():
        ids = [r["id"] for r in cat(qa)]
        dup = [v for i, v in enumerate(ids) if ids.index(v) != i]
        return (not dup, "unique" if not dup else "dup " + ",".join(map(str, dup)))
    screen(qa, "catalogue ids unique", ev)


# ---------------------------------------------------------------- product page Thens


@then(parsers.parse("the product page name, price and SKU equal row {pid:d}"))
def product_matches(qa, pid):
    def ev():
        p = qa.screen.get("product")
        row = qa.store.get("SELECT * FROM products WHERE id = ?", pid)
        if not p:
            return (False, "no product page")
        return (p["name"] == row["name"] and p["priceText"] == money(row["price_cents"]) and p["sku"] == row["sku"], f"{p['name']} {p['priceText']} {p['sku']}")
    screen(qa, f"product page == row {pid}", ev)


@then(parsers.parse("the product page stock equals row {pid:d}"))
def product_stock(qa, pid):
    def ev():
        p = qa.screen.get("product")
        row = qa.store.get("SELECT stock FROM products WHERE id = ?", pid)
        m = p and re.search(r"in stock:\s*(\d+)", p["stockText"], re.I)
        return (bool(m) and int(m.group(1)) == row["stock"], (p["stockText"] + " vs " + str(row["stock"])) if p else "no page")
    screen(qa, f"product page stock == row {pid}", ev)


@then("the product page reports not found")
def product_not_found(qa):
    def ev():
        txt = qa.mshop.page.text_content("body")
        return (re.search(r"no such product", txt, re.I) is not None, txt[:60])
    screen(qa, "product page not found", ev)


@then(parsers.parse("the product page {pid:d} is shown out of stock"))
def product_page_out(qa, pid):
    screen(qa, "product page out of stock", lambda: (bool(qa.screen.get("product")) and re.search(r"out of stock", qa.screen["product"]["stockText"], re.I) is not None, qa.screen["product"]["stockText"] if qa.screen.get("product") else "no page"))


@then("the product page price is shown as a dollar amount")
def product_price_format(qa):
    screen(qa, "product page price format", lambda: (bool(qa.screen.get("product")) and re.match(r"^\$\d+\.\d{2}$", qa.screen["product"]["priceText"]) is not None, qa.screen["product"]["priceText"] if qa.screen.get("product") else "no page"))


@then("the product page name is non-empty")
def product_name_non_empty(qa):
    screen(qa, "product page name non-empty", lambda: (bool(qa.screen.get("product")) and len(qa.screen["product"]["name"]) > 0, qa.screen["product"]["name"] if qa.screen.get("product") else "no page"))


@then(parsers.parse("the product page SKU equals row {pid:d}"))
def product_sku(qa, pid):
    def ev():
        row = qa.store.get("SELECT sku FROM products WHERE id = ?", pid)
        p = qa.screen.get("product")
        return (bool(p) and p["sku"] == row["sku"], (p["sku"] + " vs " + row["sku"]) if p else "no page")
    screen(qa, f"product page SKU == row {pid}", ev)


# ---------------------------------------------------------------- order page Thens


@then("the order page total equals the stored order total")
def order_total(qa):
    def ev():
        o = qa.screen.get("order")
        row = qa.store.get("SELECT total_cents FROM orders WHERE id = ?", qa.noted["order"]["id"])
        return (bool(o) and o["totalText"] == money(row["total_cents"]), (o["totalText"] + " vs " + money(row["total_cents"])) if o else "no order page")
    screen(qa, "order page total == stored", ev)


@then(parsers.parse('the order page shows the order id and status "{status}"'))
def order_id_status(qa, status):
    def ev():
        o = qa.screen.get("order")
        return (bool(o) and str(qa.noted["order"]["id"]) in o["idText"] and o["statusText"] == status, (o["idText"] + " / " + o["statusText"]) if o else "no order page")
    screen(qa, "order page id + status", ev)


@then("the order page total is shown as a dollar amount")
def order_total_format(qa):
    screen(qa, "order page total format", lambda: (bool(qa.screen.get("order")) and re.match(r"^\$\d+\.\d{2}$", qa.screen["order"]["totalText"]) is not None, qa.screen["order"]["totalText"] if qa.screen.get("order") else "no page"))


@then("the order page reports not found")
def order_not_found(qa):
    def ev():
        txt = qa.mshop.page.text_content("body")
        return (re.search(r"no such order", txt, re.I) is not None, txt[:60])
    screen(qa, "order page not found", ev)
