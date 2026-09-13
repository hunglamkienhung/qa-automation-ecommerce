"""Locust load test for the mini-shop service.

The performance counterpart to the functional BDD suite: the same REST API,
driven under concurrency. The user classes model the real traffic mix -- lots
of browsing, fewer checkouts -- and every request validates its response so a
wrong status counts as a failure, not just a slow success.

Run it headless with a pass/fail gate (see perf/run.sh):

    locust -f perf/locustfile.py --headless -u 40 -r 10 -t 30s \
        --host http://127.0.0.1:8090
"""

from __future__ import annotations

import os
import random
import time

from locust import HttpUser, between, events, task

MAX_FAIL_RATIO = float(os.environ.get("PERF_MAX_FAIL_RATIO", "0.01"))
MAX_P95_MS = float(os.environ.get("PERF_MAX_P95_MS", "750"))

ACTIVE_PRODUCTS = [1, 2, 4, 7, 8]        # active, in-stock seed products (6 is out of stock by design)
SEARCH_TERMS = ["Shoe", "Top", "Dress", "Shirt"]
COUPONS = ["SAVE10", "TENOFF"]

# A store under sustained load legitimately sells out a SKU: adding to a cart or
# checking out then returns 409 insufficient_stock. That is a correct, fast
# business response -- not a server error -- so the write tasks accept it. Only
# an unexpected status (a 5xx, a wrong code) counts as a failure.


def _get(client, path, name, token=None, expect=(200,)):
    headers = {"authorization": "Bearer " + token} if token else {}
    with client.get(path, headers=headers, name=name, catch_response=True) as r:
        r.success() if r.status_code in expect else r.failure(f"{r.status_code} {r.text[:80]}")
        return r


def _post(client, path, name, token=None, json=None, expect=(200, 201)):
    headers = {"authorization": "Bearer " + token} if token else {}
    with client.post(path, json=json, headers=headers, name=name, catch_response=True) as r:
        r.success() if r.status_code in expect else r.failure(f"{r.status_code} {r.text[:80]}")
        return r


class Shopper(HttpUser):
    """Browses the catalogue: listings, a product page, categories, search."""

    weight = 6
    wait_time = between(0.1, 0.5)

    @task(5)
    def browse(self):
        _get(self.client, "/products?limit=100", "GET /products")
        _get(self.client, f"/products/{random.choice(ACTIVE_PRODUCTS)}", "GET /products/[id]")

    @task(2)
    def categories(self):
        _get(self.client, "/categories", "GET /categories")

    @task(2)
    def search(self):
        _get(self.client, f"/search?q={random.choice(SEARCH_TERMS)}", "GET /search")


class Buyer(HttpUser):
    """Registers, fills a cart and checks out."""

    weight = 3
    wait_time = between(0.2, 0.8)

    @task
    def checkout(self):
        email = f"load+{int(time.time()*1000)}{random.randint(0,99999)}@example.test"
        reg = _post(self.client, "/auth/register", "POST /auth/register", json={"email": email, "name": "Load", "password": "pw-secret-123"})
        if reg.status_code != 201:
            return
        token = reg.json()["token"]
        cart = _post(self.client, "/cart", "POST /cart", token=token)
        if cart.status_code != 201:
            return
        ct = cart.json()["token"]
        added = 0
        for _ in range(random.randint(1, 3)):
            a = _post(self.client, f"/cart/{ct}/items", "POST /cart/[t]/items", token=token, json={"product_id": random.choice(ACTIVE_PRODUCTS), "qty": 1}, expect=(200, 409))
            if a.status_code == 200:
                added += 1
        if added == 0:
            return   # every SKU sold out under load -- a real client would not check out an empty cart
        order = _post(self.client, "/checkout", "POST /checkout", token=token, json={"cart_token": ct}, expect=(201, 409))
        if order.status_code == 201:
            _get(self.client, f"/orders/{order.json()['id']}", "GET /orders/[id]", token=token)


class CouponUser(HttpUser):
    """Applies a coupon to a subtotal -- a pure pricing endpoint."""

    weight = 1
    wait_time = between(0.3, 1.0)

    @task
    def apply(self):
        _post(self.client, "/coupons/apply", "POST /coupons/apply", json={"code": random.choice(COUPONS), "subtotal_cents": random.choice([6000, 10000, 15000])}, expect=(200, 400))


@events.quitting.add_listener
def _gate(environment, **_kw):
    stats = environment.stats.total
    p95 = stats.get_response_time_percentile(0.95)
    print(f"\nperf gate: requests={stats.num_requests} fails={stats.num_failures} "
          f"fail_ratio={stats.fail_ratio:.4f} p95={p95}ms rps={stats.total_rps:.1f}")
    reasons = []
    if stats.num_requests == 0:
        reasons.append("no requests were made")
    if stats.fail_ratio > MAX_FAIL_RATIO:
        reasons.append(f"fail ratio {stats.fail_ratio:.4f} > {MAX_FAIL_RATIO}")
    if p95 and p95 > MAX_P95_MS:
        reasons.append(f"p95 {p95}ms > {MAX_P95_MS}ms")
    if reasons:
        print("perf gate FAILED: " + "; ".join(reasons))
        environment.process_exit_code = 1
    else:
        print("perf gate PASSED")
        environment.process_exit_code = 0
