'use strict';

const { Given, When, Then } = require('@cucumber/cucumber');
const { MiniShopPage, ScreenNotReady } = require('../pages/minishop');
const { MiniShop, ApiUnreachable } = require('../../../be/api/venues/minishop');

/**
 * Steps for features/fe-minishop.feature -- the only steps in this domain that
 * drive a browser. The comparison figures come from the store (this.store,
 * opened by the @minishop Before hook) and the API, so the FE branch checks the
 * screen against the same rows the BE branch reads.
 */

const shop = new MiniShop();
const money = (c) => '$' + (c / 100).toFixed(2);

Given('the storefront is open', { timeout: 90_000 }, async function () {
  this.mshop = new MiniShopPage(this.page);
  await this.fetchOrBlock([ScreenNotReady], async () => { await this.mshop.open('/'); this.screen.catalogue = await this.mshop.catalogue(); });
});

async function screen(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  let r;
  try { r = await fn(); } catch (err) { if (err instanceof ScreenNotReady || err instanceof ApiUnreachable) { world.unobservable(description, err.message); return; } throw err; }
  world.check(description, r.passed, r.detail);
}
function activeRows(world) { return world.store.all('SELECT * FROM products WHERE active = 1 ORDER BY id'); }

// ---------------------------------------------------------------- navigation

When('the product page for {int} is opened', { timeout: 90_000 }, async function (pid) {
  await this.fetchOrBlock([ScreenNotReady], async () => { await this.mshop.open('/product/' + pid); this.screen.product = await this.mshop.product().catch(() => null); });
});
Given('a placed order of {int} of product {int}', { timeout: 60_000 }, async function (qty, pid) { await placeOrder(this, [[qty, pid]]); });
Given('a placed order of {int} of product {int} and {int} of product {int}', { timeout: 60_000 }, async function (q1, p1, q2, p2) { await placeOrder(this, [[q1, p1], [q2, p2]]); });
Given('a placed order of {int} of product {int} with coupon {string}', { timeout: 60_000 }, async function (qty, pid, code) { await placeOrder(this, [[qty, pid]], code); });
async function placeOrder(world, lines, coupon) {
  if (world.sourceError) return;
  try {
    const buyer = await shop.register(); const cart = await shop.openCart();
    for (const [qty, pid] of lines) await shop.addItem(cart, pid, qty);
    const r = await shop.checkout(buyer.token, { cart_token: cart, ...(coupon ? { coupon } : {}) });
    world.noted.order = r.body;
  } catch (err) { if (err instanceof ApiUnreachable) world.sourceError = err.message; else throw err; }
}
When('the order page is opened', { timeout: 90_000 }, async function () {
  await this.fetchOrBlock([ScreenNotReady], async () => { await this.mshop.open('/order/' + this.noted.order.id); this.screen.order = await this.mshop.order().catch(() => null); });
});
When('the order page for {int} is opened', { timeout: 90_000 }, async function (id) {
  await this.fetchOrBlock([ScreenNotReady], async () => { await this.mshop.open('/order/' + id); this.screen.order = await this.mshop.order().catch(() => null); });
});

// ---------------------------------------------------------------- catalogue Thens

Then('the catalogue lists the active products, once each', async function () {
  await screen(this, 'catalogue == active products', async () => { const ids = this.screen.catalogue.map((r) => r.id).sort((a, b) => a - b); const want = activeRows(this).map((r) => r.id); return { passed: JSON.stringify(ids) === JSON.stringify(want), detail: `screen ${ids.length}, active ${want.length}` }; });
});
Then('every catalogue price on screen equals the product row', async function () {
  await screen(this, 'catalogue prices == rows', async () => { const bad = this.screen.catalogue.filter((r) => { const row = this.store.get('SELECT price_cents FROM products WHERE id = ?', r.id); return r.priceText !== money(row.price_cents); }); return { passed: bad.length === 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : this.screen.catalogue.length + ' prices match' }; });
});
Then('every catalogue name on screen equals the product row', async function () {
  await screen(this, 'catalogue names == rows', async () => { const bad = this.screen.catalogue.filter((r) => { const row = this.store.get('SELECT name FROM products WHERE id = ?', r.id); return r.name !== row.name; }); return { passed: bad.length === 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : 'names match' }; });
});
Then('product {int} is shown out of stock', async function (pid) {
  await screen(this, 'product ' + pid + ' out of stock', async () => { const r = this.screen.catalogue.find((x) => x.id === pid); return { passed: !!r && /out of stock/i.test(r.stockText), detail: r ? r.stockText : 'not on catalogue' }; });
});
Then('product {int} is shown in stock', async function (pid) {
  await screen(this, 'product ' + pid + ' in stock', async () => { const r = this.screen.catalogue.find((x) => x.id === pid); return { passed: !!r && /in stock/i.test(r.stockText), detail: r ? r.stockText : 'not on catalogue' }; });
});
Then('the catalogue does not list product {int}', async function (pid) {
  await screen(this, 'catalogue excludes ' + pid, async () => ({ passed: !this.screen.catalogue.some((r) => r.id === pid), detail: 'ids ' + this.screen.catalogue.map((r) => r.id).join(',') }));
});
Then('every catalogue price is shown as a dollar amount', async function () {
  await screen(this, 'prices are dollar amounts', async () => { const bad = this.screen.catalogue.filter((r) => !/^\$\d+\.\d{2}$/.test(r.priceText)); return { passed: bad.length === 0, detail: bad.length ? bad.map((r) => r.priceText).join(',') : 'all dollar amounts' }; });
});
Then('the catalogue shows at least one product', async function () {
  await screen(this, 'catalogue non-empty', async () => ({ passed: this.screen.catalogue.length > 0, detail: this.screen.catalogue.length + ' products' }));
});
Then('the catalogue price for product {int} equals its row', async function (pid) {
  await screen(this, 'catalogue price ' + pid, async () => { const r = this.screen.catalogue.find((x) => x.id === pid); const row = this.store.get('SELECT price_cents FROM products WHERE id = ?', pid); return { passed: !!r && r.priceText === money(row.price_cents), detail: r ? r.priceText + ' vs ' + money(row.price_cents) : 'not on catalogue' }; });
});
Then('the catalogue count equals the API active product count', async function () {
  await screen(this, 'catalogue count == API active count', async () => { const r = await shop.get('/products?limit=100'); return { passed: this.screen.catalogue.length === r.body.total, detail: `screen ${this.screen.catalogue.length}, api ${r.body.total}` }; });
});
Then('each catalogue row links to its product page', async function () {
  await screen(this, 'rows link to product pages', async () => { const links = await this.page.$$eval('ul.catalogue li.product a', (els) => els.map((e) => e.getAttribute('href'))); const bad = links.filter((h) => !/^\/product\/\d+$/.test(h)); return { passed: bad.length === 0 && links.length > 0, detail: bad.length ? bad.join(',') : links.length + ' links' }; });
});
Then('every catalogue stock label is in stock or out of stock', async function () {
  await screen(this, 'stock labels known', async () => { const bad = this.screen.catalogue.filter((r) => !/^(in stock|out of stock)$/i.test(r.stockText)); return { passed: bad.length === 0, detail: bad.length ? bad.map((r) => r.stockText).join(',') : 'all known' }; });
});
Then('no catalogue product id appears twice', async function () {
  await screen(this, 'catalogue ids unique', async () => { const ids = this.screen.catalogue.map((r) => r.id); const dup = ids.filter((v, i) => ids.indexOf(v) !== i); return { passed: dup.length === 0, detail: dup.length ? 'dup ' + dup.join(',') : ids.length + ' unique' }; });
});

// ---------------------------------------------------------------- product page Thens

Then('the product page name, price and SKU equal row {int}', async function (pid) {
  await screen(this, 'product page == row ' + pid, async () => { const p = this.screen.product; const row = this.store.get('SELECT * FROM products WHERE id = ?', pid); if (!p) return { passed: false, detail: 'no product page' }; return { passed: p.name === row.name && p.priceText === money(row.price_cents) && p.sku === row.sku, detail: `${p.name} ${p.priceText} ${p.sku}` }; });
});
Then('the product page stock equals row {int}', async function (pid) {
  await screen(this, 'product page stock == row ' + pid, async () => { const p = this.screen.product; const row = this.store.get('SELECT stock FROM products WHERE id = ?', pid); const shown = p && /in stock:\s*(\d+)/i.exec(p.stockText); return { passed: !!shown && Number(shown[1]) === row.stock, detail: p ? p.stockText + ' vs ' + row.stock : 'no page' }; });
});
Then('the product page reports not found', async function () {
  await screen(this, 'product page not found', async () => { const txt = await this.page.textContent('body'); return { passed: /no such product/i.test(txt), detail: txt.slice(0, 60) }; });
});
Then('the product page {int} is shown out of stock', async function (_pid) {
  await screen(this, 'product page out of stock', async () => ({ passed: !!this.screen.product && /out of stock/i.test(this.screen.product.stockText), detail: this.screen.product ? this.screen.product.stockText : 'no page' }));
});
Then('the product page price is shown as a dollar amount', async function () {
  await screen(this, 'product page price format', async () => ({ passed: !!this.screen.product && /^\$\d+\.\d{2}$/.test(this.screen.product.priceText), detail: this.screen.product ? this.screen.product.priceText : 'no page' }));
});
Then('the product page name is non-empty', async function () {
  await screen(this, 'product page name non-empty', async () => ({ passed: !!this.screen.product && this.screen.product.name.length > 0, detail: this.screen.product ? this.screen.product.name : 'no page' }));
});
Then('the product page SKU equals row {int}', async function (pid) {
  await screen(this, 'product page SKU == row ' + pid, async () => { const row = this.store.get('SELECT sku FROM products WHERE id = ?', pid); return { passed: !!this.screen.product && this.screen.product.sku === row.sku, detail: this.screen.product ? this.screen.product.sku + ' vs ' + row.sku : 'no page' }; });
});

// ---------------------------------------------------------------- order page Thens

Then('the order page total equals the stored order total', async function () {
  await screen(this, 'order page total == stored', async () => { const o = this.screen.order; const row = this.store.get('SELECT total_cents FROM orders WHERE id = ?', this.noted.order.id); return { passed: !!o && o.totalText === money(row.total_cents), detail: o ? o.totalText + ' vs ' + money(row.total_cents) : 'no order page' }; });
});
Then('the order page shows the order id and status {string}', async function (status) {
  await screen(this, 'order page id + status', async () => { const o = this.screen.order; return { passed: !!o && o.idText.includes(String(this.noted.order.id)) && o.statusText === status, detail: o ? o.idText + ' / ' + o.statusText : 'no order page' }; });
});
Then('the order page total is shown as a dollar amount', async function () {
  await screen(this, 'order page total format', async () => ({ passed: !!this.screen.order && /^\$\d+\.\d{2}$/.test(this.screen.order.totalText), detail: this.screen.order ? this.screen.order.totalText : 'no page' }));
});
Then('the order page reports not found', async function () {
  await screen(this, 'order page not found', async () => { const txt = await this.page.textContent('body'); return { passed: /no such order/i.test(txt), detail: txt.slice(0, 60) }; });
});
