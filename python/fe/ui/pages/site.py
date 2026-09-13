"""Page object for the live storefront, automationexercise.com. Mirror of
node/fe/ui/pages/site.js. Reads the grid, search and brand rail by label; a
page that never renders raises ScreenNotReady (grades Blocked)."""

from __future__ import annotations

import os

BASE = os.environ.get("SITE_URL", "https://automationexercise.com").rstrip("/")


class ScreenNotReady(Exception):
    pass


class SitePage:
    def __init__(self, page) -> None:
        self.page = page
        self.base = BASE

    def open_products(self):
        try:
            self.page.goto(self.base + "/products", wait_until="domcontentloaded", timeout=30000)
            self.page.wait_for_selector(".features_items .product-image-wrapper", timeout=25000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady(f"products page did not render: {err}") from err

    def products(self):
        return self.page.eval_on_selector_all(".features_items .product-image-wrapper .productinfo", """els => els.map(el => ({
            name: el.querySelector('p') ? el.querySelector('p').textContent.trim() : '',
            priceText: el.querySelector('h2') ? el.querySelector('h2').textContent.trim() : '',
        }))""")

    def search(self, term):
        try:
            self.page.goto(self.base + "/products", wait_until="domcontentloaded", timeout=30000)
            self.page.fill("#search_product", term)
            self.page.click("#submit_search")
            self.page.wait_for_selector(".features_items", timeout=25000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady(f"search did not render: {err}") from err
        return self.products()

    def open_brands(self):
        try:
            self.page.goto(self.base + "/products", wait_until="domcontentloaded", timeout=30000)
            self.page.wait_for_selector(".brands_products .brands-name a", timeout=25000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady(f"brands rail did not render: {err}") from err
        import re
        raw = self.page.eval_on_selector_all(".brands_products .brands-name a", "els => els.map(e => e.textContent)")
        return [b for b in (re.sub(r"\(\d+\)", "", t).strip() for t in raw) if b]
