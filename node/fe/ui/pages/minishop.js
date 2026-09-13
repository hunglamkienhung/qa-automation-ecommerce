'use strict';

/**
 * Page object for the mini-shop HTML pages. The server renders small,
 * labelled pages (a class per figure), so the page object reads by label and
 * the assertions are about the shop, not about the markup.
 *
 * The base URL is the running service; a page that never loads (service down)
 * surfaces as ScreenNotReady, which the steps turn into Blocked.
 */

const BASE = (process.env.MINI_SHOP_URL || 'http://127.0.0.1:8090').replace(/\/+$/, '');

class ScreenNotReady extends Error {}

class MiniShopPage {
  constructor(page) { this.page = page; this.base = BASE; }

  async open(path = '/') {
    try { await this.page.goto(this.base + path, { waitUntil: 'domcontentloaded', timeout: 15_000 }); }
    catch (err) { throw new ScreenNotReady('mini-shop page ' + path + ' did not load: ' + err.message); }
  }

  /** The catalogue rows: one per product, with name, price text and stock label. */
  async catalogue() {
    await this.page.waitForSelector('ul.catalogue li.product', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('catalogue never rendered'); });
    return this.page.$$eval('ul.catalogue li.product', (els) => els.map((el) => ({
      id: Number(el.getAttribute('data-id')),
      name: el.querySelector('a') ? el.querySelector('a').textContent.trim() : '',
      priceText: el.querySelector('.price') ? el.querySelector('.price').textContent.trim() : '',
      stockText: el.querySelector('.stock') ? el.querySelector('.stock').textContent.trim() : '',
    })));
  }

  async product() {
    await this.page.waitForSelector('h1.name', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('product page never rendered'); });
    const read = async (sel) => (await this.page.$(sel)) ? (await this.page.$eval(sel, (e) => e.textContent.trim())) : null;
    return { name: await read('h1.name'), priceText: await read('.price'), sku: await read('.sku'), stockText: await read('.stock') };
  }

  async order() {
    await this.page.waitForSelector('h1.order-id', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('order page never rendered'); });
    return { idText: await this.page.$eval('h1.order-id', (e) => e.textContent.trim()), totalText: await this.page.$eval('.total', (e) => e.textContent.trim()), statusText: await this.page.$eval('.status', (e) => e.textContent.trim()) };
  }
}

module.exports = { MiniShopPage, ScreenNotReady, BASE };
