"""Steps for be-minishop-db.feature and the shared "drive the service" Givens.
Mirror of node/be/db/steps/shop.steps.js -- a plugin module.

Isolation is by delta, not reset. `{x:dec}` is a decimal-ish literal; here all
quantities are ints so plain {int} suffices.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest
from pytest_bdd import given, parsers, then, when

from be.api.venues.minishop import ApiUnreachable, MiniShop
from be.db.store import DbUnreachable, Store, throwaway

shop = MiniShop()
UNREACHABLE = (DbUnreachable, ApiUnreachable)
SEED = Path(__file__).resolve().parents[4] / "services" / "mini-shop" / "db" / "seed.sql"


@pytest.fixture(autouse=True)
def shop_scenario(request, qa):
    if request.node.get_closest_marker("minishop") is None:
        yield
        return
    qa.store = None
    qa.shop = shop
    qa.buyer = None
    qa.cart_token = None
    qa.noted = {}
    qa.last = None
    qa.api = None
    qa.tmp = None
    yield
    if qa.tmp is not None:
        qa.tmp.close()
    if qa.store is not None:
        qa.store.close()


def act(qa, fn):
    if qa.source_error:
        return None
    try:
        return fn()
    except UNREACHABLE as err:
        qa.source_error = str(err)
        return None


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


def order_of(qa):
    return qa.last["body"] if qa.last and qa.last.get("status") == 201 else None


# ---------------------------------------------------------------- Background


@given("the store is open and the service is reachable")
def store_open(qa):
    if qa.source_error:
        return
    try:
        qa.store = Store()
    except DbUnreachable as err:
        qa.source_error = str(err)
        return
    r = act(qa, lambda: shop.get("/categories"))
    if qa.source_error:
        return
    if not r or r["status"] != 200:
        qa.source_error = "mini-shop did not answer /categories"
    qa.evidence("storeFile", str(qa.store.file))


# ---------------------------------------------------------------- drive the service


@given("a registered buyer with a cart")
def buyer_with_cart(qa):
    def go():
        qa.buyer = shop.register()
        qa.cart_token = shop.open_cart()
    act(qa, go)


def add_to_cart(qa, qty, pid):
    def go():
        r = shop.add_item(qa.cart_token, pid, qty)
        if r["status"] != 200:
            raise RuntimeError("add item failed: " + str(r["status"]) + " " + r["text"])
    act(qa, go)


@given(parsers.parse("the cart holds {qty:d} of product {pid:d}"))
def cart_holds(qa, qty, pid):
    add_to_cart(qa, qty, pid)


@given(parsers.parse("the cart holds {q1:d} of product {p1:d} and {q2:d} of product {p2:d}"))
def cart_holds2(qa, q1, p1, q2, p2):
    add_to_cart(qa, q1, p1)
    add_to_cart(qa, q2, p2)


@given(parsers.parse("the cart holds {q1:d} of product {p1:d} and {q2:d} of product {p2:d} and {q3:d} of product {p3:d}"))
def cart_holds3(qa, q1, p1, q2, p2, q3, p3):
    add_to_cart(qa, q1, p1)
    add_to_cart(qa, q2, p2)
    add_to_cart(qa, q3, p3)


@when(parsers.parse("the buyer adds {qty:d} of product {pid:d} to the cart"))
def buyer_adds(qa, qty, pid):
    add_to_cart(qa, qty, pid)


@given(parsers.parse("the stock of product {pid:d} is noted"))
def note_stock(qa, pid):
    if qa.store:
        qa.noted[f"stock.{pid}"] = qa.store.get("SELECT stock FROM products WHERE id = ?", pid)["stock"]


@given("the order count is noted")
def note_orders(qa):
    if qa.store:
        qa.noted["orders"] = qa.store.count("orders")


@given(parsers.parse('the redemption count of coupon "{code}" is noted'))
def note_redeem(qa, code):
    if qa.store:
        qa.noted[f"redeem.{code}"] = qa.store.get("SELECT redeemed FROM coupons WHERE code = ?", code)["redeemed"]


@given(parsers.parse('coupon "{code}" has been fully redeemed'))
def coupon_exhausted(qa, code):
    def go():
        b = shop.register()
        cart = shop.open_cart()
        shop.add_item(cart, 1, 1)
        shop.checkout(b["token"], {"cart_token": cart, "coupon": code})
    act(qa, go)


def do_checkout(qa, body):
    def go():
        qa.last = shop.checkout(qa.buyer["token"], {"cart_token": qa.cart_token, **body})
        qa.api = qa.last
        return qa.last
    return act(qa, go)


@when("the buyer checks out")
def checks_out(qa):
    do_checkout(qa, {})


@given("the buyer checks out")
def checks_out_given(qa):
    do_checkout(qa, {})


@when(parsers.parse('the buyer checks out with coupon "{code}"'))
def checks_out_coupon(qa, code):
    do_checkout(qa, {"coupon": code})


@when(parsers.parse('the buyer checks out with idempotency key "{key}"'))
def checks_out_key(qa, key):
    qa.noted["firstOrder"] = do_checkout(qa, {"idempotency_key": key})


@when(parsers.parse('the buyer checks out again with idempotency key "{key}"'))
def checks_out_key2(qa, key):
    qa.noted["secondOrder"] = do_checkout(qa, {"idempotency_key": key})


@when(parsers.parse("the buyer tries to check out {qty:d} of product {pid:d}"))
def tries_checkout(qa, qty, pid):
    def go():
        r = shop.add_item(qa.cart_token, pid, qty)
        qa.last = shop.checkout(qa.buyer["token"], {"cart_token": qa.cart_token}) if r["status"] == 200 else r
    act(qa, go)


@when(parsers.parse("the buyer checks out {qty:d} of product {pid:d}, {times:d} times"))
def checks_out_times(qa, qty, pid, times):
    def go():
        for _ in range(times):
            b = shop.register()
            cart = shop.open_cart()
            if shop.add_item(cart, pid, qty)["status"] == 200:
                shop.checkout(b["token"], {"cart_token": cart})
    act(qa, go)


# ---------------------------------------------------------------- schema (throwaway)


@then(parsers.re(r"the store has tables (?P<lst>.+)"))
def store_has_tables(qa, lst):
    want = [t.strip() for t in lst.split(",")]

    def ev():
        have = qa.store.tables()
        missing = [t for t in want if t not in have]
        return (not missing, "missing " + ", ".join(missing) if missing else f"{len(have)} tables")
    check(qa, "store has the documented tables", ev)


@given("a throwaway database with the schema applied")
def throwaway_db(qa):
    qa.tmp = throwaway()
    qa.tmp.execute("INSERT INTO categories (id, slug, name) VALUES (1, 'x', 'X')")
    qa.tmp.execute("INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (1, 'S1', 'P', 1, 100, 10)")
    qa.tmp.execute("INSERT INTO customers (id, email, name, password_hash, created_at) VALUES (1, 'a@b.c', 'A', 'h', 1)")
    qa.tmp.execute("INSERT INTO carts (id, token, created_at) VALUES (1, 't', 1)")
    qa.tmp.execute("INSERT INTO orders (id, customer_id, cart_id, subtotal_cents, total_cents, created_at) VALUES (1, 1, 1, 100, 100, 1)")


@given("a throwaway database with the schema and seed applied")
def throwaway_seeded(qa):
    qa.tmp = throwaway()
    qa.tmp.executescript(SEED.read_text(encoding="utf-8"))


def _fails(db, sql, params, needle):
    import sqlite3
    try:
        db.execute(sql, params)
        return (False, "insert succeeded")
    except sqlite3.Error as err:
        return (needle in str(err), str(err))


@then("inserting two products with the same SKU fails on the second")
def sku_unique(qa):
    def ev():
        a = _fails(qa.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (2,'DUP','A',1,1,1)", (), "\0")
        if a[1] != "insert succeeded":
            return (False, "first: " + a[1])
        return _fails(qa.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (3,'DUP','B',1,1,1)", (), "UNIQUE constraint failed: products.sku")
    qa.observe("sku UNIQUE", ev)


@then("inserting an order_items row for a missing order fails a FOREIGN KEY")
def oi_order_fk(qa):
    qa.observe("order_items.order_id FK", lambda: _fails(qa.tmp, "INSERT INTO order_items (order_id, product_id, qty, price_cents) VALUES (999,1,1,1)", (), "FOREIGN KEY constraint failed"))


@then("inserting an order_items row for a missing product fails a FOREIGN KEY")
def oi_product_fk(qa):
    qa.observe("order_items.product_id FK", lambda: _fails(qa.tmp, "INSERT INTO order_items (order_id, product_id, qty, price_cents) VALUES (1,999,1,1)", (), "FOREIGN KEY constraint failed"))


@then("inserting a product with negative price fails a CHECK")
def neg_price(qa):
    qa.observe("price_cents >= 0", lambda: _fails(qa.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (4,'N1','P',1,-1,1)", (), "CHECK constraint failed"))


@then("inserting a product with negative stock fails a CHECK")
def neg_stock(qa):
    qa.observe("stock >= 0", lambda: _fails(qa.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (5,'N2','P',1,1,-1)", (), "CHECK constraint failed"))


@then("inserting a cart item with zero quantity fails a CHECK")
def zero_qty(qa):
    qa.observe("qty > 0", lambda: _fails(qa.tmp, "INSERT INTO cart_items (cart_id, product_id, qty) VALUES (1,1,0)", (), "CHECK constraint failed"))


@then("inserting a stock movement with zero delta fails a CHECK")
def zero_delta(qa):
    qa.observe("delta <> 0", lambda: _fails(qa.tmp, "INSERT INTO stock_movements (product_id, delta, reason, created_at) VALUES (1,0,'seed',1)", (), "CHECK constraint failed"))


@then(parsers.parse('inserting a stock movement with reason "{reason}" fails a CHECK'))
def bad_reason(qa, reason):
    qa.observe("reason CHECK", lambda: _fails(qa.tmp, "INSERT INTO stock_movements (product_id, delta, reason, created_at) VALUES (1,1,?,1)", (reason,), "CHECK constraint failed"))


@then("applying the seed again changes no row counts")
def seed_idempotent(qa):
    def ev():
        tabs = ["products", "categories", "coupons", "stock_movements"]
        before = [qa.tmp.execute("SELECT COUNT(*) FROM " + t).fetchone()[0] for t in tabs]
        qa.tmp.executescript(SEED.read_text(encoding="utf-8"))
        after = [qa.tmp.execute("SELECT COUNT(*) FROM " + t).fetchone()[0] for t in tabs]
        return (before == after, f"before {before}, after {after}")
    qa.observe("seed idempotent", ev)


# ---------------------------------------------------------------- checkout <-> rows


@then("the order total equals the sum of its line amounts")
def total_eq_lines(qa):
    def ev():
        o = order_of(qa)
        if not o:
            return (False, "no order: " + json.dumps(qa.last and qa.last.get("body")))
        s = sum(it["line_cents"] for it in o["items"])
        row = qa.store.get("SELECT * FROM orders WHERE id = ?", o["id"])
        return (row["total_cents"] == o["total_cents"] and row["subtotal_cents"] - row["discount_cents"] == row["total_cents"] and s == row["subtotal_cents"], f"rowsub {row['subtotal_cents']} disc {row['discount_cents']} total {row['total_cents']}, lines {s}")
    check(qa, "order total == sum lines", ev)


@then("each order line price equals the product's price at purchase")
def line_price(qa):
    def ev():
        o = order_of(qa)
        bad = [it for it in o["items"] if it["price_cents"] != qa.store.get("SELECT price_cents FROM products WHERE id = ?", it["product_id"])["price_cents"]]
        return (not bad, json.dumps(bad) if bad else f"{len(o['items'])} lines match")
    check(qa, "order line price == product price", ev)


@then(parsers.parse("the stock of product {pid:d} fell by {d:d}"))
def stock_fell(qa, pid, d):
    check(qa, f"stock of {pid} fell by {d}", lambda: ((lambda now: (qa.noted[f"stock.{pid}"] - now == d, f"before {qa.noted[f'stock.{pid}']}, now {now}"))(qa.store.get("SELECT stock FROM products WHERE id = ?", pid)["stock"])))


@then(parsers.parse('a stock movement of {delta:d} for product {pid:d} with reason "{reason}" is linked to the order'))
def movement_linked(qa, delta, pid, reason):
    def ev():
        o = order_of(qa)
        m = qa.store.get("SELECT * FROM stock_movements WHERE order_id = ? AND product_id = ?", o["id"], pid)
        return (bool(m) and m["delta"] == delta and m["reason"] == reason, f"delta {m['delta']}, reason {m['reason']}" if m else "no movement")
    check(qa, f"movement {delta} for {pid}", ev)


@then(parsers.parse("the sum of movements for product {pid:d} equals its current stock"))
def ledger_eq_stock(qa, pid):
    check(qa, f"ledger of {pid} == stock", lambda: ((lambda le, st: (le == st, f"ledger {le}, stock {st}"))(qa.store.ledger_stock(pid), qa.store.get("SELECT stock FROM products WHERE id = ?", pid)["stock"])))


@then(parsers.parse('the checkout is refused with code "{code}"'))
def checkout_refused(qa, code):
    qa.observe("checkout refused: " + code, lambda: (bool(qa.last and qa.last.get("status", 0) >= 400 and qa.last.get("body") and qa.last["body"].get("code") == code), (str(qa.last.get("status")) + " " + json.dumps(qa.last.get("body"))) if qa.last else "no response"))


@then(parsers.parse("the stock of product {pid:d} is unchanged"))
def stock_unchanged(qa, pid):
    check(qa, f"stock of {pid} unchanged", lambda: ((lambda now: (now == qa.noted[f"stock.{pid}"], f"before {qa.noted[f'stock.{pid}']}, now {now}"))(qa.store.get("SELECT stock FROM products WHERE id = ?", pid)["stock"])))


@then("no new order was created")
def no_new_order(qa):
    check(qa, "order count unchanged", lambda: ((lambda n: (n == qa.noted["orders"], f"before {qa.noted['orders']}, now {n}"))(qa.store.count("orders"))))


@then(parsers.parse('the cart row status is "{status}"'))
def cart_status(qa, status):
    check(qa, "cart status " + status, lambda: ((lambda c: (bool(c) and c["status"] == status, c["status"] if c else "no cart"))(qa.store.get("SELECT status FROM carts WHERE token = ?", qa.cart_token))))


@then("the order's customer is the buyer")
def order_customer(qa):
    def ev():
        o = order_of(qa)
        row = qa.store.get("SELECT customer_id FROM orders WHERE id = ?", o["id"])
        return (row["customer_id"] == qa.buyer["id"], f"order {row['customer_id']}, buyer {qa.buyer['id']}")
    check(qa, "order.customer_id == buyer", ev)


@then(parsers.parse("the order has {n:d} order lines"))
def order_lines(qa, n):
    check(qa, f"order has {n} lines", lambda: ((lambda c: (c == n, f"lines {c}"))(qa.store.count("order_items", "WHERE order_id = ?", order_of(qa)["id"]))))


@then(parsers.parse("the order discount is {pct:d} percent of the subtotal"))
def discount_pct(qa, pct):
    def ev():
        r = qa.store.get("SELECT * FROM orders WHERE id = ?", order_of(qa)["id"])
        return (r["discount_cents"] == r["subtotal_cents"] * pct // 100, f"subtotal {r['subtotal_cents']}, discount {r['discount_cents']}")
    check(qa, f"discount == {pct}% subtotal", ev)


@then("the order total is the subtotal minus the discount")
def total_minus_discount(qa):
    check(qa, "total == subtotal - discount", lambda: ((lambda r: (r["total_cents"] == r["subtotal_cents"] - r["discount_cents"], f"{r['subtotal_cents']} - {r['discount_cents']} = {r['total_cents']}"))(qa.store.get("SELECT * FROM orders WHERE id = ?", order_of(qa)["id"]))))


@then("the order total equals the subtotal minus the discount on the row")
def total_minus_discount_pos(qa):
    check(qa, "row total == subtotal - discount", lambda: ((lambda r: (r["total_cents"] == r["subtotal_cents"] - r["discount_cents"] and r["discount_cents"] > 0, f"{r['subtotal_cents']} - {r['discount_cents']} = {r['total_cents']}"))(qa.store.get("SELECT * FROM orders WHERE id = ?", order_of(qa)["id"]))))


@then(parsers.parse('the redemption count of coupon "{code}" grew by {d:d}'))
def redeem_grew(qa, code, d):
    check(qa, f"redeemed of {code} grew by {d}", lambda: ((lambda now: (now - qa.noted[f"redeem.{code}"] == d, f"before {qa.noted[f'redeem.{code}']}, now {now}"))(qa.store.get("SELECT redeemed FROM coupons WHERE code = ?", code)["redeemed"])))


@then("exactly one new order was created")
def exactly_one_order(qa):
    check(qa, "exactly one new order", lambda: ((lambda n: (n == qa.noted["orders"] + 1, f"before {qa.noted['orders']}, now {n}"))(qa.store.count("orders"))))


@then("both checkouts returned the same order id")
def same_order_id(qa):
    def ev():
        a, b = qa.noted.get("firstOrder"), qa.noted.get("secondOrder")
        return (bool(a and b and a.get("body") and b.get("body") and a["body"]["id"] == b["body"]["id"]), f"first {a and a['body'].get('id')}, second {b and b['body'].get('id')}")
    qa.observe("idempotent replay returns same order", ev)


@then("no order_items row references a product missing from products")
def no_orphan_line(qa):
    check(qa, "no orphan order line", lambda: ((lambda n: (n == 0, f"{n} orphans"))(qa.store.count("order_items oi", "WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.id = oi.product_id)"))))


@then("no orders row references a cart missing from carts")
def no_orphan_cart(qa):
    check(qa, "no orphan order->cart", lambda: ((lambda n: (n == 0, f"{n} orphans"))(qa.store.count("orders o", "WHERE NOT EXISTS (SELECT 1 FROM carts c WHERE c.id = o.cart_id)"))))


@then("the order subtotal equals the sum of quantity times captured price")
def subtotal_eq_sum(qa):
    def ev():
        o = order_of(qa)
        r = qa.store.get("SELECT subtotal_cents FROM orders WHERE id = ?", o["id"])
        s = sum(it["qty"] * it["price_cents"] for it in qa.store.all("SELECT qty, price_cents FROM order_items WHERE order_id = ?", o["id"]))
        return (r["subtotal_cents"] == s, f"subtotal {r['subtotal_cents']}, sum {s}")
    check(qa, "subtotal == sum qty*price", ev)


@then(parsers.parse("the stock of product {pid:d} is not negative"))
def stock_not_negative(qa, pid):
    check(qa, f"stock of {pid} >= 0", lambda: ((lambda s: (s >= 0, f"stock {s}"))(qa.store.get("SELECT stock FROM products WHERE id = ?", pid)["stock"])))


@then(parsers.parse("a cart_items row holds {qty:d} of product {pid:d}"))
def cart_line(qa, qty, pid):
    def ev():
        cart = qa.store.get("SELECT id FROM carts WHERE token = ?", qa.cart_token)
        it = cart and qa.store.get("SELECT qty FROM cart_items WHERE cart_id = ? AND product_id = ?", cart["id"], pid)
        return (bool(it) and it["qty"] == qty, f"qty {it['qty']}" if it else "no cart line")
    check(qa, f"cart line {qty}x{pid}", ev)


@then(parsers.parse("the seed movements for product {pid:d} sum to a stock at or above its current stock"))
def seed_ledger(qa, pid):
    check(qa, "ledger >= stock", lambda: ((lambda le, st: (le >= st and le > 0, f"ledger {le}, stock {st}"))(qa.store.ledger_stock(pid), qa.store.get("SELECT stock FROM products WHERE id = ?", pid)["stock"])))
