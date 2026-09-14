"""Steps for be-minishop-security.feature. Mirror of
node/be/api/steps/security.steps.js -- a plugin module. Adversarial probes of
the authentication surface; Background, store, and buyer/cart Givens are shared
from the other @minishop steps.
"""

from __future__ import annotations

import json
import time

from pytest_bdd import parsers, then, when

from be.api.venues.minishop import ApiUnreachable, MiniShop
from be.db.store import DbUnreachable

shop = MiniShop()
UNREACHABLE = (ApiUnreachable, DbUnreachable)
FORGED = "cust_forged000000000000000000"


def send(qa, method, path, **opts):
    if qa.source_error:
        return
    try:
        qa.api = shop.request(method, path, **opts)
        qa.last = qa.api
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


def body_text(qa):
    return json.dumps((qa.api or {}).get("body") or {})


# ---------------------------------------------------------------- forged / tampered


@when("checkout is posted with a forged token")
def checkout_forged(qa):
    send(qa, "POST", "/checkout", token=FORGED, body={"cart_token": qa.cart_token})


@when("the buyer checks out with a token that extends their own")
def checkout_tampered(qa):
    send(qa, "POST", "/checkout", token=qa.buyer["token"] + "x", body={"cart_token": qa.cart_token})


@when("the order is read with a forged token")
def order_read_forged(qa):
    send(qa, "GET", "/orders/" + str(qa.last["body"]["id"]), token=FORGED)


# ---------------------------------------------------------------- login: enumeration / lockout


@when("a login is attempted for an unregistered email")
def login_unregistered(qa):
    send(qa, "POST", "/auth/login", body={"email": f"ghost+{int(time.time()*1000)}@example.test", "password": "x"})


@when(parsers.parse("the buyer fails to log in {n:d} times"))
def fail_logins(qa, n):
    for _ in range(n):
        send(qa, "POST", "/auth/login", body={"email": qa.buyer["email"], "password": "definitely-wrong"})


# ---------------------------------------------------------------- secret hygiene


@then("the response carries no password hash")
def no_password_hash(qa):
    def ev():
        t = body_text(qa)
        leaks = [p for p in ("sha256$", "password_hash", "password") if p in t]
        return (not leaks, "leaked " + ",".join(leaks) if leaks else "clean")
    check(qa, "no password hash leaked", ev)


@then("the response carries no token and no password hash")
def no_credential(qa):
    def ev():
        t = body_text(qa)
        leaks = [p for p in ("cust_", "sha256$", "password_hash", "token") if p in t]
        return (not leaks, "leaked " + ",".join(leaks) if leaks else "clean")
    check(qa, "no credential leaked", ev)
