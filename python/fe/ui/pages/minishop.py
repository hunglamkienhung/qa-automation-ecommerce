"""Page object for the mini-shop HTML pages. Mirror of node/fe/ui/pages/minishop.js.
Reads by label; a page that never loads raises ScreenNotReady (grades Blocked)."""

from __future__ import annotations

import os

BASE = os.environ.get("MINI_SHOP_URL", "http://127.0.0.1:8090").rstrip("/")


class ScreenNotReady(Exception):
    pass


class MiniShopPage:
    def __init__(self, page) -> None:
        self.page = page
        self.base = BASE

    def open(self, path="/"):
        try:
            self.page.goto(self.base + path, wait_until="domcontentloaded", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady(f"mini-shop page {path} did not load: {err}") from err

    def catalogue(self):
        try:
            self.page.wait_for_selector("ul.catalogue li.product", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("catalogue never rendered") from err
        return self.page.eval_on_selector_all("ul.catalogue li.product", """els => els.map(el => ({
            id: Number(el.getAttribute('data-id')),
            name: el.querySelector('a') ? el.querySelector('a').textContent.trim() : '',
            priceText: el.querySelector('.price') ? el.querySelector('.price').textContent.trim() : '',
            stockText: el.querySelector('.stock') ? el.querySelector('.stock').textContent.trim() : '',
        }))""")

    def product(self):
        try:
            self.page.wait_for_selector("h1.name", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("product page never rendered") from err

        def read(sel):
            el = self.page.query_selector(sel)
            return el.text_content().strip() if el else None
        return {"name": read("h1.name"), "priceText": read(".price"), "sku": read(".sku"), "stockText": read(".stock")}

    def order(self):
        try:
            self.page.wait_for_selector("h1.order-id", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("order page never rendered") from err
        return {"idText": self.page.eval_on_selector("h1.order-id", "e => e.textContent.trim()"), "totalText": self.page.eval_on_selector(".total", "e => e.textContent.trim()"), "statusText": self.page.eval_on_selector(".status", "e => e.textContent.trim()")}
