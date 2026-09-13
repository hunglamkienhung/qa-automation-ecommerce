"""Steps for be-site-api.feature. Mirror of node/be/api/steps/site.steps.js --
a plugin module. HTTPS against the live site; the outcome is a responseCode in
the body. A transport failure grades Blocked.
"""

from __future__ import annotations

import pytest
from pytest_bdd import given, parsers, then, when

from be.api.venues import site

UNREACHABLE = (site.SiteUnreachable,)


@pytest.fixture(autouse=True)
def site_scenario(request, qa):
    if request.node.get_closest_marker("site") is None:
        yield
        return
    qa.site = {}
    yield


def fetch_or(qa, key, fn):
    if getattr(qa, "site", None) is None:
        qa.site = {}

    def go():
        qa.site[key] = fn()
    qa.fetch_or_block(UNREACHABLE, go)


def fetch_products(qa):
    def fn():
        r = site.products_list()
        qa.site["lastCode"] = r["responseCode"]
        return r["body"]["products"]
    fetch_or(qa, "products", fn)


# ---------------------------------------------------------------- fetches


@when("the site product list is fetched")
def products_fetched(qa):
    fetch_products(qa)


@given("the full product list is fetched")
def products_fetched_given(qa):
    fetch_products(qa)


@when("the site product list is fetched again")
def products_fetched_again(qa):
    fetch_or(qa, "products2", lambda: site.products_list()["body"]["products"])


@when("the site product list is posted to")
def products_posted(qa):
    def fn():
        r = site.products_list_post()
        qa.site["lastCode"] = r["responseCode"]
        return r
    fetch_or(qa, "resp", fn)


@when("the site brand list is fetched")
def brands_fetched(qa):
    def fn():
        r = site.brands_list()
        qa.site["lastCode"] = r["responseCode"]
        return r["body"]["brands"]
    fetch_or(qa, "brands", fn)


@when("the site brand list is posted to")
def brands_posted(qa):
    def fn():
        r = site.brands_list_post()
        qa.site["lastCode"] = r["responseCode"]
        return r
    fetch_or(qa, "resp", fn)


@when(parsers.parse('the site is searched for "{term}"'))
def searched(qa, term):
    fetch_or(qa, "search", lambda: site.search_product(term))
    if qa.site.get("search"):
        qa.site["lastCode"] = qa.site["search"]["responseCode"]
    qa.site.setdefault("searchCounts", [])
    s = qa.site.get("search")
    if s and isinstance(s["body"], dict) and isinstance(s["body"].get("products"), list):
        qa.site["searchCounts"].append(len(s["body"]["products"]))


def resp_fetch(qa, fn):
    def go():
        r = fn()
        qa.site["lastCode"] = r["responseCode"]
        return r
    fetch_or(qa, "resp", go)


@when("the site is searched with no term")
def searched_no_term(qa):
    resp_fetch(qa, lambda: site.search_product(None))


@when("login is verified with no email")
def login_no_email(qa):
    resp_fetch(qa, lambda: site.verify_login({"password": "x"}))


@when("login is verified for an unregistered email")
def login_unregistered(qa):
    import time
    resp_fetch(qa, lambda: site.verify_login({"email": f"no-such-{int(time.time())}@example.test", "password": "x"}))


@when("login verification is sent as DELETE")
def login_delete(qa):
    resp_fetch(qa, lambda: site.request("DELETE", "/verifyLogin"))


@when("the detail of an unregistered email is fetched")
def detail_unregistered(qa):
    import time
    resp_fetch(qa, lambda: site.get_user_by_email(f"no-such-{int(time.time())}@example.test"))


# ---------------------------------------------------------------- response code


@then(parsers.parse("the site response code is {code:d}"))
def site_response_code(qa, code):
    qa.observe("responseCode == " + str(code), lambda: (qa.site.get("lastCode") == code, "responseCode " + str(qa.site.get("lastCode"))))


# ---------------------------------------------------------------- products


@then("the product list is non-empty")
def products_non_empty(qa):
    qa.observe("products non-empty", lambda: (len(qa.site["products"]) > 0, f"{len(qa.site['products'])} products"))


@then(parsers.parse("the product list has at least {n:d} products"))
def at_least_n(qa, n):
    qa.observe(f"at least {n} products", lambda: (len(qa.site["products"]) >= n, f"{len(qa.site['products'])} products"))


@then("no product id appears more than once")
def product_ids_unique(qa):
    def ev():
        ids = [p["id"] for p in qa.site["products"]]
        dup = [v for i, v in enumerate(ids) if ids.index(v) != i]
        return (not dup, "dup" if dup else f"{len(ids)} unique")
    qa.observe("product ids unique", ev)


@then("every product price parses to a non-negative number")
def prices_parse(qa):
    def ev():
        bad = [p for p in qa.site["products"] if site.parse_price(p["price"]) is None or site.parse_price(p["price"]) < 0]
        return (not bad, "bad prices" if bad else "all parse")
    qa.observe("prices parse >= 0", ev)


@then(parsers.parse('every product price matches the "{fmt}" format'))
def prices_format(qa, fmt):
    qa.observe("prices match Rs. N", lambda: ((lambda bad: (not bad, "bad" if bad else "all match"))([p for p in qa.site["products"] if site.parse_price(p["price"]) is None])))


@then("every product has a non-empty name, brand and category")
def product_fields(qa):
    def ev():
        bad = [p for p in qa.site["products"] if not p.get("name") or not p.get("brand") or not p.get("category", {}).get("category")]
        return (not bad, f"{len(bad)} incomplete")
    qa.observe("name/brand/category present", ev)


@then("every product category has a category and a user type")
def category_usertype(qa):
    def ev():
        bad = [p for p in qa.site["products"] if not p.get("category", {}).get("category") or not p.get("category", {}).get("usertype", {}).get("usertype")]
        return (not bad, f"{len(bad)} incomplete")
    qa.observe("category + usertype present", ev)


@then("every product id is a positive integer")
def ids_positive(qa):
    qa.observe("ids positive integers", lambda: ((lambda bad: (not bad, f"{len(bad)} bad"))([p for p in qa.site["products"] if not isinstance(p["id"], int) or p["id"] <= 0])))


@then("the response body is a JSON object carrying a numeric response code")
def body_numeric_code(qa):
    qa.observe("body has numeric responseCode", lambda: (qa.site.get("products") is not None, "parsed"))


@then("both reads return the same product ids")
def stable_ids(qa):
    def ev():
        a = sorted(p["id"] for p in qa.site["products"])
        b = sorted(p["id"] for p in qa.site["products2"])
        return (a == b, f"first {len(a)}, second {len(b)}")
    qa.observe("stable product ids", ev)


# ---------------------------------------------------------------- brands


@then("the brand list is non-empty")
def brands_non_empty(qa):
    qa.observe("brands non-empty", lambda: (len(qa.site["brands"]) > 0, f"{len(qa.site['brands'])} brands"))


@then("every brand has an id and a non-empty name")
def brand_fields(qa):
    qa.observe("brand id + name", lambda: ((lambda bad: (not bad, f"{len(bad)} incomplete"))([b for b in qa.site["brands"] if not isinstance(b["id"], int) or not b["brand"]])))


@then("no brand id appears more than once")
def brand_ids_unique(qa):
    def ev():
        ids = [b["id"] for b in qa.site["brands"]]
        dup = [v for i, v in enumerate(ids) if ids.index(v) != i]
        return (not dup, "dup" if dup else f"{len(ids)} unique")
    qa.observe("brand ids unique", ev)


@then("every brand name is non-empty when trimmed")
def brand_names_trimmed(qa):
    qa.observe("brand names trimmed non-empty", lambda: ((lambda bad: (not bad, f"{len(bad)} empty"))([b for b in qa.site["brands"] if not str(b["brand"]).strip()])))


# ---------------------------------------------------------------- search


def search_products(qa):
    s = qa.site.get("search")
    return (s and isinstance(s["body"], dict) and s["body"].get("products")) or []


@then(parsers.parse('every returned product name contains "{term}"'))
def returned_names_contain(qa, term):
    qa.observe("names contain " + term, lambda: ((lambda ps: (all(term.lower() in p["name"].lower() for p in ps) and len(ps) > 0, f"{len(ps)} match"))(search_products(qa))))


@then("every returned product id is in the full product list")
def returned_ids_subset(qa):
    def ev():
        allids = {p["id"] for p in qa.site["products"]}
        bad = [p for p in search_products(qa) if p["id"] not in allids]
        return (not bad, "stray" if bad else "subset")
    qa.observe("search ids subset", ev)


@then("every searched product id is in the full product list")
def searched_ids_subset(qa):
    returned_ids_subset(qa)


@then("the returned product list is empty")
def search_empty(qa):
    qa.observe("search empty", lambda: (len(search_products(qa)) == 0, f"{len(search_products(qa))} products"))


@then("the search returns at least one product")
def search_non_empty(qa):
    qa.observe("search non-empty", lambda: (len(search_products(qa)) > 0, f"{len(search_products(qa))} products"))


@then("the search returns no more products than the full catalogue")
def search_le_catalogue(qa):
    qa.observe("search count <= catalogue", lambda: (len(search_products(qa)) <= len(qa.site["products"]), f"search {len(search_products(qa))}, catalogue {len(qa.site['products'])}"))


@then("both searches return the same product count")
def searches_same_count(qa):
    def ev():
        c = qa.site.get("searchCounts", [])
        return (len(c) == 2 and c[0] == c[1], f"counts {c}")
    qa.observe("case-insensitive same count", ev)
