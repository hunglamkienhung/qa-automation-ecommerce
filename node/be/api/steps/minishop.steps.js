'use strict';

const { Given, When, Then } = require('@cucumber/cucumber');
const { MiniShop, ApiUnreachable } = require('../venues/minishop');
const { DbUnreachable } = require('../../db/store');

/**
 * Steps for features/be-minishop-api.feature: the REST layer compared with the
 * rows it serves. The Background, the store, and the "drive the service" Givens
 * are shared from be/db/steps/shop.steps.js. `this.api` is always the last
 * response.
 */

const shop = new MiniShop();
const UNREACHABLE = [ApiUnreachable, DbUnreachable];
const j = (v) => JSON.stringify(v);

async function send(world, method, path, opts = {}) {
  if (world.sourceError) return;
  try { world.api = await shop.request(method, path, opts); } catch (err) {
    if (err instanceof ApiUnreachable) { world.sourceError = err.message; return; }
    throw err;
  }
}
async function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  let r;
  try { r = await fn(); } catch (err) { if (UNREACHABLE.some((C) => err instanceof C)) { world.unobservable(description, err.message); return; } throw err; }
  world.check(description, r.passed, r.detail);
}
function body(world) { return (world.api && world.api.body) || {}; }
function field(world, n) { return body(world)[n]; }
const eq = (a, b) => String(a) === String(b);

function productRowView(store, row) {
  return { id: row.id, sku: row.sku, name: row.name, category_id: row.category_id, price_cents: row.price_cents, price: '$' + (row.price_cents / 100).toFixed(2), stock: row.stock, in_stock: row.stock > 0 };
}

// ---------------------------------------------------------------- requests

When(/^GET (\/\S*)$/, { timeout: 30_000 }, async function (path) { await send(this, 'GET', path); });
When(/^POST \/cart$/, { timeout: 30_000 }, async function () { await send(this, 'POST', '/cart'); });
When('GET the cart', { timeout: 30_000 }, async function () { await send(this, 'GET', '/cart/' + this.cartToken); });

Given('a fresh cart', { timeout: 30_000 }, async function () {
  if (this.sourceError) return;
  try { this.cartToken = await shop.openCart(); } catch (err) { if (err instanceof ApiUnreachable) this.sourceError = err.message; else throw err; }
});
async function addItems(world, qty, pid) { await send(world, 'POST', `/cart/${world.cartToken}/items`, { body: { product_id: pid, qty } }); }
When('{int} of product {int} are added to the cart', { timeout: 30_000 }, async function (qty, pid) { await addItems(this, qty, pid); });
Given('{int} of product {int} in the cart', { timeout: 30_000 }, async function (qty, pid) { await addItems(this, qty, pid); });
When('the quantity of product {int} is set to {int}', { timeout: 30_000 }, async function (pid, qty) { await send(this, 'PATCH', `/cart/${this.cartToken}/items/${pid}`, { body: { qty } }); });

When('the coupon {string} is applied to a subtotal of {int}', { timeout: 30_000 }, async function (code, sub) { await send(this, 'POST', '/coupons/apply', { body: { code, subtotal_cents: sub } }); });

// auth / checkout (uses shared this.buyer / this.cartToken from shop.steps.js)
When('a buyer registers', { timeout: 30_000 }, async function () {
  if (this.sourceError) return;
  this.noted.regEmail = 'buyer+' + Date.now() + Math.random().toString(36).slice(2, 7) + '@example.test';
  await send(this, 'POST', '/auth/register', { body: { email: this.noted.regEmail, name: 'Reg', password: 'pw-123456' } });
});
When('the same email registers again', { timeout: 30_000 }, async function () { await send(this, 'POST', '/auth/register', { body: { email: this.noted.regEmail, name: 'Reg', password: 'pw-123456' } }); });
Given('a registered buyer', { timeout: 30_000 }, async function () { if (!this.sourceError) { try { this.buyer = await shop.register(); } catch (e) { if (e instanceof ApiUnreachable) this.sourceError = e.message; else throw e; } } });
When('the buyer logs in with the right password', { timeout: 30_000 }, async function () { await send(this, 'POST', '/auth/login', { body: { email: this.buyer.email, password: this.buyer.password } }); });
When('the buyer logs in with a wrong password', { timeout: 30_000 }, async function () { await send(this, 'POST', '/auth/login', { body: { email: this.buyer.email, password: 'wrong' } }); });
When('checkout is posted with no token', { timeout: 30_000 }, async function () { await send(this, 'POST', '/checkout', { body: { cart_token: this.cartToken } }); });
When('the owner reads the order', { timeout: 30_000 }, async function () { await send(this, 'GET', '/orders/' + this.last.body.id, { token: this.buyer.token }); });
When('a different buyer reads the order', { timeout: 30_000 }, async function () { const other = await shop.register(); await send(this, 'GET', '/orders/' + this.last.body.id, { token: other.token }); });
When('the order is read with no token', { timeout: 30_000 }, async function () { await send(this, 'GET', '/orders/' + this.last.body.id); });

When('the products are paged {int} at a time', { timeout: 30_000 }, async function (n) {
  this.noted.paged = [];
  for (let page = 1; page < 100; page++) {
    await send(this, 'GET', `/products?page=${page}&limit=${n}`);
    if (this.sourceError || this.api.status !== 200) break;
    this.noted.paged.push(...body(this).products);
    if (body(this).products.length < n) break;
  }
});

// ---------------------------------------------------------------- Then: status/shape

Then(/^the response status is (\d+)$/, async function (s) { await check(this, 'status ' + s, () => ({ passed: this.api.status === Number(s), detail: 'status ' + this.api.status + ' ' + (this.api.text || '').slice(0, 140) })); });
Then(/^the response is an error with code "([^"]*)"$/, async function (code) { await check(this, 'error code ' + code, () => { const b = body(this); return { passed: b.code === code && typeof b.error === 'string', detail: (this.api.text || '').slice(0, 140) }; }); });
Then(/^the response field "([^"]+)" is (-?\d+)$/, async function (n, v) { await check(this, `${n} == ${v}`, () => ({ passed: field(this, n) === Number(v), detail: n + ' = ' + j(field(this, n)) })); });
Then('the response list {string} has {int} entries', async function (n, k) { await check(this, `${n} has ${k}`, () => { const l = field(this, n); return { passed: Array.isArray(l) && l.length === k, detail: Array.isArray(l) ? l.length + ' entries' : 'not a list' }; }); });
Then('the response has a token', async function () { await check(this, 'response has a token', () => ({ passed: typeof field(this, 'token') === 'string' && field(this, 'token').length > 0, detail: 'token ' + (field(this, 'token') ? 'present' : 'absent') })); });
Then('the response field {string} is at most the subtotal {int}', async function (n, sub) { await check(this, `${n} <= ${sub}`, () => ({ passed: field(this, n) <= sub, detail: n + ' = ' + field(this, n) })); });

// ---------------------------------------------------------------- Then: products/catalogue

Then('every product in the response matches its row', async function () {
  await check(this, 'products match rows', () => { const bad = (field(this, 'products') || []).filter((p) => { const row = this.store.get('SELECT * FROM products WHERE id = ?', p.id); return !row || j(productRowView(this.store, row)) !== j(p); }); return { passed: bad.length === 0, detail: bad.length ? 'mismatch ' + j(bad.slice(0, 2)) : (field(this, 'products') || []).length + ' match' }; });
});
Then('no inactive product appears', async function () {
  await check(this, 'no inactive product', () => { const ids = (field(this, 'products') || []).map((p) => p.id); const bad = ids.filter((id) => { const r = this.store.get('SELECT active FROM products WHERE id = ?', id); return r && r.active === 0; }); return { passed: bad.length === 0, detail: bad.length ? 'inactive ' + bad.join(',') : 'all active' }; });
});
Then('the paged products are exactly the active products, each once', async function () {
  await check(this, 'paged == active products', () => { const got = (this.noted.paged || []).map((p) => p.id).sort((a, b) => a - b); const want = this.store.all('SELECT id FROM products WHERE active = 1 ORDER BY id').map((r) => r.id); const dup = got.filter((v, i) => i > 0 && got[i - 1] === v); return { passed: j(got) === j(want) && dup.length === 0, detail: `paged ${got.length}, active ${want.length}, dup ${dup.length}` }; });
});
Then('the response field {string} equals the count of active products', async function (n) { await check(this, n + ' == active count', () => { const c = this.store.count('products', 'WHERE active = 1'); return { passed: field(this, n) === c, detail: `api ${field(this, n)}, store ${c}` }; }); });
Then('every product in the response has category_id {int}', async function (cat) { await check(this, 'all in category ' + cat, () => { const bad = (field(this, 'products') || []).filter((p) => p.category_id !== cat); return { passed: bad.length === 0 && (field(this, 'products') || []).length > 0, detail: bad.length + ' off-category' }; }); });
Then('the response field {string} equals the count of active products in category {int}', async function (n, cat) { await check(this, n + ' == active in cat', () => { const c = this.store.count('products', 'WHERE active = 1 AND category_id = ?', cat); return { passed: field(this, n) === c, detail: `api ${field(this, n)}, store ${c}` }; }); });
Then('the products are ordered by ascending price', async function () { await check(this, 'ordered by price', () => { const ps = (field(this, 'products') || []).map((p) => p.price_cents); const ok = ps.every((v, i) => i === 0 || ps[i - 1] <= v); return { passed: ok && ps.length > 1, detail: ps.slice(0, 6).join(',') }; }); });
Then('the product in the response matches row {int}', async function (id) { await check(this, 'product == row ' + id, () => { const row = this.store.get('SELECT * FROM products WHERE id = ?', id); return { passed: j(body(this)) === j(productRowView(this.store, row)), detail: j(body(this)) }; }); });
Then('the categories in the response equal the category rows', async function () { await check(this, 'categories == rows', () => { const rows = this.store.all('SELECT * FROM categories ORDER BY id'); const got = field(this, 'categories') || []; return { passed: got.length === rows.length && rows.every((r, i) => got[i] && eq(got[i].id, r.id) && got[i].slug === r.slug && got[i].name === r.name), detail: `api ${got.length}, store ${rows.length}` }; }); });
Then('every product name contains {string}', async function (term) { await check(this, 'names contain ' + term, () => { const bad = (field(this, 'products') || []).filter((p) => !p.name.toLowerCase().includes(term.toLowerCase())); return { passed: bad.length === 0 && (field(this, 'products') || []).length > 0, detail: bad.length ? bad.map((p) => p.name).join(',') : 'all contain' }; }); });

// ---------------------------------------------------------------- Then: cart

Then('the cart subtotal is {int}', async function (v) { await check(this, 'subtotal ' + v, () => ({ passed: field(this, 'subtotal_cents') === v, detail: 'subtotal ' + field(this, 'subtotal_cents') })); });
Then('the cart has {int} items', async function (n) { await check(this, 'cart has ' + n + ' items', () => { const items = field(this, 'items') || []; return { passed: items.length === n, detail: items.length + ' items' }; }); });
Then('the cart holds {int} of product {int} priced from the row', async function (qty, pid) { await check(this, `cart holds ${qty}×${pid}`, () => { const it = (field(this, 'items') || []).find((x) => x.product_id === pid); const row = this.store.get('SELECT price_cents FROM products WHERE id = ?', pid); return { passed: !!it && it.qty === qty && it.price_cents === row.price_cents && it.line_cents === qty * row.price_cents, detail: it ? j(it) : 'no line' }; }); });
Then('the cart subtotal equals the sum of its line totals', async function () { await check(this, 'subtotal == Σ lines', () => { const items = field(this, 'items') || []; const sum = items.reduce((s, it) => s + it.line_cents, 0); return { passed: field(this, 'subtotal_cents') === sum, detail: `subtotal ${field(this, 'subtotal_cents')}, Σ ${sum}` }; }); });

// ---------------------------------------------------------------- Then: checkout/orders

function orderRowView(store, id) {
  const o = store.get('SELECT * FROM orders WHERE id = ?', id);
  if (!o) return null;
  const items = store.all('SELECT * FROM order_items WHERE order_id = ? ORDER BY id', id).map((it) => ({ product_id: it.product_id, qty: it.qty, price_cents: it.price_cents, line_cents: it.qty * it.price_cents }));
  return { id: o.id, customer_id: o.customer_id, subtotal_cents: o.subtotal_cents, discount_cents: o.discount_cents, total_cents: o.total_cents, coupon_code: o.coupon_code, status: o.status, items };
}
Then('the order in the response equals the stored order', async function () {
  await check(this, 'order == stored order', () => { const b = body(this); const row = orderRowView(this.store, b.id); return { passed: !!row && j({ ...b, idempotent_replay: undefined }) === j({ ...row, idempotent_replay: undefined }), detail: row ? 'api ' + j(b) : 'no order row' }; });
});
Then('the order total in the response equals the sum of its line amounts', async function () {
  await check(this, 'order total == Σ lines', () => { const b = body(this); const sum = (b.items || []).reduce((s, it) => s + it.line_cents, 0); return { passed: b.total_cents === sum && b.discount_cents === 0, detail: `total ${b.total_cents}, Σ ${sum}` }; });
});
