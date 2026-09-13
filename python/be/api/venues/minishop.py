"""HTTP client for the mini-shop service. Mirror of node/be/api/venues/minishop.js.
urllib only. A transport failure is ApiUnreachable (grades Blocked); a 4xx/5xx
is an answer, often the one under test.
"""

from __future__ import annotations

import json
import os
import time
import urllib.error
import urllib.request

BASE = os.environ.get("MINI_SHOP_URL", "http://127.0.0.1:8090").rstrip("/")


class ApiUnreachable(Exception):
    pass


class MiniShop:
    def __init__(self, base: str = BASE) -> None:
        self.base = base

    def request(self, method, path, token=None, body=None, headers=None):
        h = dict(headers or {})
        if token:
            h["Authorization"] = "Bearer " + token
        data = None
        if body is not None:
            h["Content-Type"] = "application/json"
            data = json.dumps(body).encode()
        req = urllib.request.Request(self.base + path, data=data, headers=h, method=method)
        try:
            with urllib.request.urlopen(req, timeout=15) as res:
                status, text = res.status, res.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as err:
            status, text = err.code, err.read().decode("utf-8", "replace")
        except (urllib.error.URLError, TimeoutError, OSError) as err:
            raise ApiUnreachable(f"mini-shop at {self.base} did not answer {method} {path}: {err}") from err
        try:
            parsed = json.loads(text) if text else None
        except json.JSONDecodeError:
            parsed = None
        return {"status": status, "body": parsed, "text": text}

    def get(self, p, **kw):
        return self.request("GET", p, **kw)

    def post(self, p, body=None, **kw):
        return self.request("POST", p, body=body, **kw)

    def patch(self, p, body=None, **kw):
        return self.request("PATCH", p, body=body, **kw)

    def register(self, name="Test Buyer"):
        email = f"buyer+{int(time.time()*1000)}{os.urandom(3).hex()}@example.test"
        r = self.post("/auth/register", {"email": email, "name": name, "password": "pw-secret-123"})
        if r["status"] != 201:
            raise RuntimeError("register failed: HTTP " + str(r["status"]) + " " + r["text"])
        return {**r["body"], "password": "pw-secret-123"}

    def open_cart(self):
        r = self.post("/cart")
        if r["status"] != 201:
            raise RuntimeError("open cart failed: HTTP " + str(r["status"]) + " " + r["text"])
        return r["body"]["token"]

    def add_item(self, cart_token, product_id, qty):
        return self.post(f"/cart/{cart_token}/items", {"product_id": product_id, "qty": qty})

    def checkout(self, token, body):
        return self.post("/checkout", body, token=token)
