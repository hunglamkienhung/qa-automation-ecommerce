'use strict';

/**
 * Page object for the live storefront, automationexercise.com. Reads the
 * products grid, the search results, and the brand rail by their labels, so
 * the assertions are about the store, not the markup. A page that never
 * renders is ScreenNotReady, which the steps turn into Blocked -- a live site
 * being slow or down is not the site being wrong.
 */

const BASE = (process.env.SITE_URL || 'https://automationexercise.com').replace(/\/+$/, '');

class ScreenNotReady extends Error {}

class SitePage {
  constructor(page) { this.page = page; this.base = BASE; }

  async openProducts() {
    try {
      await this.page.goto(this.base + '/products', { waitUntil: 'domcontentloaded', timeout: 30_000 });
      await this.page.waitForSelector('.features_items .product-image-wrapper', { timeout: 25_000 });
    } catch (err) { throw new ScreenNotReady('products page did not render: ' + err.message); }
  }

  /** Product cards: name and price text, in grid order. */
  async products() {
    return this.page.$$eval('.features_items .product-image-wrapper .productinfo', (els) => els.map((el) => ({
      name: el.querySelector('p') ? el.querySelector('p').textContent.trim() : '',
      priceText: el.querySelector('h2') ? el.querySelector('h2').textContent.trim() : '',
    })));
  }

  async search(term) {
    try {
      await this.page.goto(this.base + '/products', { waitUntil: 'domcontentloaded', timeout: 30_000 });
      await this.page.fill('#search_product', term);
      await this.page.click('#submit_search');
      await this.page.waitForSelector('.features_items', { timeout: 25_000 });
    } catch (err) { throw new ScreenNotReady('search did not render: ' + err.message); }
    return this.products();
  }

  async openBrands() {
    try {
      await this.page.goto(this.base + '/products', { waitUntil: 'domcontentloaded', timeout: 30_000 });
      await this.page.waitForSelector('.brands_products .brands-name a', { timeout: 25_000 });
    } catch (err) { throw new ScreenNotReady('brands rail did not render: ' + err.message); }
    return this.page.$$eval('.brands_products .brands-name a', (els) => els.map((e) => e.textContent.replace(/\(\d+\)/, '').trim()).filter(Boolean));
  }
}

module.exports = { SitePage, ScreenNotReady, BASE };
