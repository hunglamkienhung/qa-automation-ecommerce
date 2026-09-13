"""Steps for be-minishop-api.feature: the REST layer vs the rows it serves.
Mirror of node/be/api/steps/minishop.steps.js -- a plugin module. Background,
store, and "drive the service" Givens are shared from shop_steps.py.
"""

from __future__ import annotations

import json
import re
import time

from pytest_bdd import given, parsers, then, when

from be.api.venues.minishop import ApiUnreachable, MiniShop
from be.db.store import DbUnreachable

shop = MiniShop()
UNREACHABLE = (ApiUnreachable, DbUnreachable)


def send(qa, method, path, **opts):
    if qa.source_error:
        return
    try:
        qa.api = shop.request(method, path, **opts)
    except ApiUnreachable as err:
        qa.source_error = str(err)


def check(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    try:
        passed, detail = fn()
    except UNREACHABLE as err:
        qa.unobservable(description, str(err))
        return
    qa.check(description, passed, detail)


def body(qa):
    return (qa.api or {}).get("body") or {}


def field(qa, n):
    return body(qa).get(n)


def product_view(row):
    return {"id": row["id"], "sku": row["sku"], "name": row["name"], "category_id": row["category_id"], "price_cents": row["price_cents"], "price": "$" + f"{row['price_cents'] / 100:.2f}", "stock": row["stock"], "in_stock": row["stock"] > 0}


# ---------------------------------------------------------------- requests


@when(parsers.re(r"^GET (?P<path>/\S*)$"))
def get_path(qa, path):
    send(qa, "GET", path)


@when(parsers.re(r"^POST /cart$"))
def post_cart(qa):
    send(qa, "POST", "/cart")


@when("GET the cart")
def get_cart(qa):
    send(qa, "GET", "/cart/" + qa.cart_token)


@given("a fresh cart")
def fresh_cart(qa):
    if qa.source_error:
        return
    try:
        qa.cart_token = shop.open_cart()
    except ApiUnreachable as err:
        qa.source_error = str(err)


def add_items(qa, qty, pid):
    send(qa, "POST", f"/cart/{qa.cart_token}/items", body={"product_id": pid, "qty": qty})


@when(parsers.parse("{qty:d} of product {pid:d} are added to the cart"))
def add_items_when(qa, qty, pid):
    add_items(qa, qty, pid)


@given(parsers.parse("{qty:d} of product {pid:d} in the cart"))
def add_items_given(qa, qty, pid):
    add_items(qa, qty, pid)


@when(parsers.parse("the quantity of product {pid:d} is set to {qty:d}"))
def set_qty(qa, pid, qty):
    send(qa, "PATCH", f"/cart/{qa.cart_token}/items/{pid}", body={"qty": qty})


@when(parsers.parse('the coupon "{code}" is applied to a subtotal of {sub:d}'))
def apply_coupon(qa, code, sub):
    send(qa, "POST", "/coupons/apply", body={"code": code, "subtotal_cents": sub})


@when("a buyer registers")
def a_buyer_registers(qa):
    if qa.source_error:
        return
    qa.noted["regEmail"] = f"buyer+{int(time.time()*1000)}{__import__('os').urandom(3).hex()}@example.test"
    send(qa, "POST", "/auth/register", body={"email": qa.noted["regEmail"], "name": "Reg", "password": "pw-123456"})


@when("the same email registers again")
def same_email(qa):
    send(qa, "POST", "/auth/register", body={"email": qa.noted["regEmail"], "name": "Reg", "password": "pw-123456"})


@given("a registered buyer")
def registered_buyer(qa):
    if qa.source_error:
        return
    try:
        qa.buyer = shop.register()
    except ApiUnreachable as err:
        qa.source_error = str(err)


@when("the buyer logs in with the right password")
def login_right(qa):
    send(qa, "POST", "/auth/login", body={"email": qa.buyer["email"], "password": qa.buyer["password"]})


@when("the buyer logs in with a wrong password")
def login_wrong(qa):
    send(qa, "POST", "/auth/login", body={"email": qa.buyer["email"], "password": "wrong"})


@when("checkout is posted with no token")
def checkout_no_token(qa):
    send(qa, "POST", "/checkout", body={"cart_token": qa.cart_token})


@when("the owner reads the order")
def owner_reads(qa):
    send(qa, "GET", "/orders/" + str(qa.last["body"]["id"]), token=qa.buyer["token"])


@when("a different buyer reads the order")
def other_reads(qa):
    other = shop.register()
    send(qa, "GET", "/orders/" + str(qa.last["body"]["id"]), token=other["token"])


@when("the order is read with no token")
def read_no_token(qa):
    send(qa, "GET", "/orders/" + str(qa.last["body"]["id"]))


@when(parsers.parse("the products are paged {n:d} at a time"))
def page_products(qa, n):
    qa.noted["paged"] = []
    for page in range(1, 100):
        send(qa, "GET", f"/products?page={page}&limit={n}")
        if qa.source_error or qa.api["status"] != 200:
            break
        qa.noted["paged"].extend(body(qa)["products"])
        if len(body(qa)["products"]) < n:
            break


# ---------------------------------------------------------------- Then: status/shape


@then(parsers.re(r"^the response status is (?P<s>\d+)$"))
def response_status(qa, s):
    check(qa, "status " + s, lambda: (qa.api["status"] == int(s), f"status {qa.api['status']} {qa.api.get('text','')[:140]}"))


@then(parsers.re(r'^the response is an error with code "(?P<code>[^"]*)"$'))
def response_error(qa, code):
    check(qa, "error code " + code, lambda: (body(qa).get("code") == code and isinstance(body(qa).get("error"), str), qa.api.get("text", "")[:140]))


@then(parsers.re(r'^the response field "(?P<n>[^"]+)" is (?P<v>-?\d+)$'))
def response_field_int(qa, n, v):
    check(qa, f"{n} == {v}", lambda: (field(qa, n) == int(v), f"{n} = {json.dumps(field(qa, n))}"))


@then(parsers.parse('the response list "{n}" has {k:d} entries'))
def response_list_len(qa, n, k):
    check(qa, f"{n} has {k}", lambda: ((lambda l: (isinstance(l, list) and len(l) == k, f"{len(l)} entries" if isinstance(l, list) else "not a list"))(field(qa, n))))


@then("the response has a token")
def has_token(qa):
    check(qa, "response has a token", lambda: (isinstance(field(qa, "token"), str) and len(field(qa, "token")) > 0, "token present" if field(qa, "token") else "absent"))


@then(parsers.parse('the response field "{n}" is at most the subtotal {sub:d}'))
def field_at_most(qa, n, sub):
    check(qa, f"{n} <= {sub}", lambda: (field(qa, n) <= sub, f"{n} = {field(qa, n)}"))


# ---------------------------------------------------------------- products


@then("every product in the response matches its row")
def products_match(qa):
    def ev():
        bad = [p for p in (field(qa, "products") or []) if json.dumps(product_view(qa.store.get("SELECT * FROM products WHERE id = ?", p["id"])), sort_keys=True) != json.dumps(p, sort_keys=True)]
        return (not bad, "mismatch" if bad else f"{len(field(qa, 'products') or [])} match")
    check(qa, "products match rows", ev)


@then("no inactive product appears")
def no_inactive(qa):
    def ev():
        bad = [p for p in (field(qa, "products") or []) if (qa.store.get("SELECT active FROM products WHERE id = ?", p["id"]) or {}).get("active") == 0]
        return (not bad, "inactive present" if bad else "all active")
    check(qa, "no inactive product", ev)


@then("the paged products are exactly the active products, each once")
def paged_products(qa):
    def ev():
        got = sorted(p["id"] for p in qa.noted.get("paged", []))
        want = [r["id"] for r in qa.store.all("SELECT id FROM products WHERE active = 1 ORDER BY id")]
        dup = [v for i, v in enumerate(got) if i > 0 and got[i - 1] == v]
        return (got == want and not dup, f"paged {len(got)}, active {len(want)}, dup {len(dup)}")
    check(qa, "paged == active", ev)


@then(parsers.parse('the response field "{n}" equals the count of active products'))
def field_active_count(qa, n):
    check(qa, n + " == active count", lambda: ((lambda c: (field(qa, n) == c, f"api {field(qa, n)}, store {c}"))(qa.store.count("products", "WHERE active = 1"))))


@then(parsers.parse("every product in the response has category_id {cat:d}"))
def all_in_category(qa, cat):
    check(qa, "all in category " + str(cat), lambda: ((lambda ps: (all(p["category_id"] == cat for p in ps) and len(ps) > 0, f"{len(ps)} products"))(field(qa, "products") or [])))


@then(parsers.parse('the response field "{n}" equals the count of active products in category {cat:d}'))
def field_active_cat(qa, n, cat):
    check(qa, n + " == active in cat", lambda: ((lambda c: (field(qa, n) == c, f"api {field(qa, n)}, store {c}"))(qa.store.count("products", "WHERE active = 1 AND category_id = ?", cat))))


@then("the products are ordered by ascending price")
def ordered_by_price(qa):
    def ev():
        ps = [p["price_cents"] for p in (field(qa, "products") or [])]
        return (all(ps[i - 1] <= ps[i] for i in range(1, len(ps))) and len(ps) > 1, ",".join(map(str, ps[:6])))
    check(qa, "ordered by price", ev)


@then(parsers.parse("the product in the response matches row {pid:d}"))
def product_matches_row(qa, pid):
    check(qa, "product == row " + str(pid), lambda: (json.dumps(body(qa), sort_keys=True) == json.dumps(product_view(qa.store.get("SELECT * FROM products WHERE id = ?", pid)), sort_keys=True), json.dumps(body(qa))))


@then("the categories in the response equal the category rows")
def categories_equal(qa):
    def ev():
        rows = qa.store.all("SELECT * FROM categories ORDER BY id")
        got = field(qa, "categories") or []
        return (len(got) == len(rows) and all(got[i]["id"] == r["id"] and got[i]["slug"] == r["slug"] and got[i]["name"] == r["name"] for i, r in enumerate(rows)), f"api {len(got)}, store {len(rows)}")
    check(qa, "categories == rows", ev)


@then(parsers.parse('every product name contains "{term}"'))
def names_contain(qa, term):
    check(qa, "names contain " + term, lambda: ((lambda ps: (all(term.lower() in p["name"].lower() for p in ps) and len(ps) > 0, f"{len(ps)} products"))(field(qa, "products") or [])))


# ---------------------------------------------------------------- cart


@then(parsers.parse("the cart subtotal is {v:d}"))
def cart_subtotal_is(qa, v):
    check(qa, "subtotal " + str(v), lambda: (field(qa, "subtotal_cents") == v, f"subtotal {field(qa, 'subtotal_cents')}"))


@then(parsers.parse("the cart has {n:d} items"))
def cart_items_n(qa, n):
    check(qa, f"cart has {n} items", lambda: ((lambda items: (len(items) == n, f"{len(items)} items"))(field(qa, "items") or [])))


@then(parsers.parse("the cart holds {qty:d} of product {pid:d} priced from the row"))
def cart_holds_priced(qa, qty, pid):
    def ev():
        it = next((x for x in (field(qa, "items") or []) if x["product_id"] == pid), None)
        row = qa.store.get("SELECT price_cents FROM products WHERE id = ?", pid)
        return (bool(it) and it["qty"] == qty and it["price_cents"] == row["price_cents"] and it["line_cents"] == qty * row["price_cents"], json.dumps(it) if it else "no line")
    check(qa, f"cart holds {qty}x{pid}", ev)


@then("the cart subtotal equals the sum of its line totals")
def cart_subtotal_lines(qa):
    def ev():
        items = field(qa, "items") or []
        s = sum(it["line_cents"] for it in items)
        return (field(qa, "subtotal_cents") == s, f"subtotal {field(qa, 'subtotal_cents')}, sum {s}")
    check(qa, "subtotal == sum lines", ev)


# ---------------------------------------------------------------- checkout/orders


def order_row_view(store, oid):
    o = store.get("SELECT * FROM orders WHERE id = ?", oid)
    if not o:
        return None
    items = [{"product_id": it["product_id"], "qty": it["qty"], "price_cents": it["price_cents"], "line_cents": it["qty"] * it["price_cents"]} for it in store.all("SELECT * FROM order_items WHERE order_id = ? ORDER BY id", oid)]
    return {"id": o["id"], "customer_id": o["customer_id"], "subtotal_cents": o["subtotal_cents"], "discount_cents": o["discount_cents"], "total_cents": o["total_cents"], "coupon_code": o["coupon_code"], "status": o["status"], "items": items}


@then("the order in the response equals the stored order")
def order_equals_stored(qa):
    def ev():
        b = dict(body(qa))
        b.pop("idempotent_replay", None)
        row = order_row_view(qa.store, b.get("id"))
        return (bool(row) and json.dumps(b, sort_keys=True) == json.dumps(row, sort_keys=True), "api " + json.dumps(b) if row else "no order row")
    check(qa, "order == stored order", ev)


@then("the order total in the response equals the sum of its line amounts")
def order_total_lines(qa):
    def ev():
        b = body(qa)
        s = sum(it["line_cents"] for it in (b.get("items") or []))
        return (b.get("total_cents") == s and b.get("discount_cents") == 0, f"total {b.get('total_cents')}, sum {s}")
    check(qa, "order total == sum lines", ev)
