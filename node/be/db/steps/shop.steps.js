'use strict';

const { Given, When, Then, Before, After } = require('@cucumber/cucumber');
const { Store, DbUnreachable, throwaway } = require('../store');
const { MiniShop, ApiUnreachable } = require('../../api/venues/minishop');

/**
 * Steps for features/be-minishop-db.feature, plus the shared "drive the
 * service" Givens that be-minishop-api.feature reuses.
 *
 * Isolation is by delta, not by reset: each scenario notes the baseline it
 * cares about (a product's stock, a coupon's redemptions, the order count),
 * drives the API to change it, and asserts the change. Fresh buyers and carts
 * mean the customer/cart/order rows never collide between scenarios.
 */

const shop = new MiniShop();
const UNREACHABLE = [DbUnreachable, ApiUnreachable];

Before({ tags: '@minishop' }, function () {
  this.store = null;
  this.shopClient = shop;
  this.buyer = null;
  this.cartToken = null;
  this.noted = {};
  this.last = null;      // last checkout/api response
  this.tmp = null;
  this.api = null;       // last HTTP response (minishop-api tier)
});

After({ tags: '@minishop' }, function () {
  if (this.tmp) { try { this.tmp.close(); } catch { /* fine */ } }
  if (this.store) this.store.close();
});

// ---------------------------------------------------------------- helpers

async function act(world, fn) {
  if (world.sourceError) return undefined;
  try { return await fn(); } catch (err) {
    if (UNREACHABLE.some((C) => err instanceof C)) { world.sourceError = err.message; return undefined; }
    throw err;
  }
}
async function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  let r;
  try { r = await fn(); } catch (err) { if (UNREACHABLE.some((C) => err instanceof C)) { world.unobservable(description, err.message); return; } throw err; }
  world.check(description, r.passed, r.detail);
}
const j = (v) => JSON.stringify(v);
const money = (c) => '$' + (c / 100).toFixed(2);

// ---------------------------------------------------------------- Background

Given('the store is open and the service is reachable', { timeout: 30_000 }, async function () {
  if (this.sourceError) return;
  try { this.store = new Store(); } catch (err) { if (err instanceof DbUnreachable) { this.sourceError = err.message; return; } throw err; }
  const r = await act(this, () => shop.get('/categories'));
  if (this.sourceError) return;
  if (!r || r.status !== 200) this.sourceError = 'mini-shop did not answer /categories: ' + (r ? r.status : 'no response');
  this.evidence('storeFile', this.store.file);
});

// ---------------------------------------------------------------- drive the service (shared with @api)

Given('a registered buyer with a cart', { timeout: 30_000 }, async function () {
  await act(this, async () => { this.buyer = await shop.register(); this.cartToken = await shop.openCart(); });
});

async function addToCart(world, qty, pid) {
  await act(world, async () => { const r = await shop.addItem(world.cartToken, pid, qty); if (r.status !== 200) throw new Error('add item failed: ' + r.status + ' ' + r.text); });
}

Given('the cart holds {int} of product {int}', { timeout: 30_000 }, async function (qty, pid) { await addToCart(this, qty, pid); });
Given('the cart holds {int} of product {int} and {int} of product {int}', { timeout: 30_000 }, async function (q1, p1, q2, p2) { await addToCart(this, q1, p1); await addToCart(this, q2, p2); });
Given('the cart holds {int} of product {int} and {int} of product {int} and {int} of product {int}', { timeout: 30_000 }, async function (q1, p1, q2, p2, q3, p3) { await addToCart(this, q1, p1); await addToCart(this, q2, p2); await addToCart(this, q3, p3); });

When('the buyer adds {int} of product {int} to the cart', { timeout: 30_000 }, async function (qty, pid) { await addToCart(this, qty, pid); });

Given('the stock of product {int} is noted', function (pid) { if (this.store) this.noted['stock.' + pid] = this.store.get('SELECT stock FROM products WHERE id = ?', pid).stock; });
Given('the order count is noted', function () { if (this.store) this.noted.orders = this.store.count('orders'); });
Given('the redemption count of coupon {string} is noted', function (code) { if (this.store) this.noted['redeem.' + code] = this.store.get('SELECT redeemed FROM coupons WHERE code = ?', code).redeemed; });

Given('coupon {string} has been fully redeemed', { timeout: 30_000 }, async function (code) {
  // spend the single-redemption coupon once, on a throwaway buyer, so the real scenario meets an exhausted coupon
  await act(this, async () => {
    const b = await shop.register(); const cart = await shop.openCart();
    await shop.addItem(cart, 1, 1);
    const r = await shop.checkout(b.token, { cart_token: cart, coupon: code });
    if (r.status !== 201 && r.body && r.body.code !== 'coupon_exhausted') { /* already exhausted by a prior run: fine */ }
  });
});

async function doCheckout(world, body) {
  return act(world, async () => { world.last = await shop.checkout(world.buyer.token, { cart_token: world.cartToken, ...body }); world.api = world.last; return world.last; });
}
When('the buyer checks out', { timeout: 30_000 }, async function () { await doCheckout(this, {}); });
When('the buyer checks out with coupon {string}', { timeout: 30_000 }, async function (code) { await doCheckout(this, { coupon: code }); });
When('the buyer checks out with idempotency key {string}', { timeout: 30_000 }, async function (key) { this.noted.firstOrder = (await doCheckout(this, { idempotency_key: key })); });
When('the buyer checks out again with idempotency key {string}', { timeout: 30_000 }, async function (key) { this.noted.secondOrder = (await doCheckout(this, { idempotency_key: key })); });
When('the buyer tries to check out {int} of product {int}', { timeout: 30_000 }, async function (qty, pid) {
  // add beyond stock is blocked at the cart; force it by checking out a cart the service will reject at checkout
  await act(this, async () => { const r = await shop.addItem(this.cartToken, pid, qty); this.last = r.status === 200 ? await shop.checkout(this.buyer.token, { cart_token: this.cartToken }) : r; });
});
When('the buyer checks out {int} of product {int}, {int} times', { timeout: 60_000 }, async function (qty, pid, times) {
  await act(this, async () => {
    for (let i = 0; i < times; i++) {
      const b = await shop.register(); const cart = await shop.openCart();
      const add = await shop.addItem(cart, pid, qty);
      if (add.status === 200) await shop.checkout(b.token, { cart_token: cart });
    }
  });
});

function order(world) { return world.last && world.last.body && world.last.status === 201 ? world.last.body : null; }

// ---------------------------------------------------------------- schema (throwaway)

Then('the store has tables {}', async function (list) {
  const want = list.split(/,\s*/);
  await check(this, 'store has the documented tables', () => { const have = this.store.tables(); const missing = want.filter((t) => !have.includes(t)); return { passed: missing.length === 0, detail: missing.length ? 'missing ' + missing.join(', ') : have.length + ' tables' }; });
});

Given('a throwaway database with the schema applied', function () {
  this.tmp = throwaway();
  this.tmp.exec("INSERT INTO categories (id, slug, name) VALUES (1, 'x', 'X')");
  this.tmp.exec("INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (1, 'S1', 'P', 1, 100, 10)");
  this.tmp.exec("INSERT INTO customers (id, email, name, password_hash, created_at) VALUES (1, 'a@b.c', 'A', 'h', 1)");
  this.tmp.exec("INSERT INTO carts (id, token, created_at) VALUES (1, 't', 1)");
  this.tmp.exec("INSERT INTO orders (id, customer_id, cart_id, subtotal_cents, total_cents, created_at) VALUES (1, 1, 1, 100, 100, 1)");
});
Given('a throwaway database with the schema and seed applied', function () {
  const fs = require('fs'); const path = require('path');
  this.tmp = throwaway();
  this.tmp.exec(fs.readFileSync(path.join(__dirname, '..', '..', '..', '..', 'services', 'mini-shop', 'db', 'seed.sql'), 'utf8'));
});

function fails(db, sql, params, re) {
  try { db.prepare(sql).run(...params); return { passed: false, detail: 'insert succeeded' }; } catch (err) { return { passed: re.test(err.message), detail: err.message }; }
}
Then('inserting two products with the same SKU fails on the second', function () {
  this.observe('sku UNIQUE', () => { const a = fails(this.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (2, 'DUP', 'A', 1, 1, 1)", [], /never/); if (a.detail !== 'insert succeeded') return { passed: false, detail: 'first: ' + a.detail }; return fails(this.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (3, 'DUP', 'B', 1, 1, 1)", [], /UNIQUE constraint failed: products\.sku/); });
});
Then('inserting an order_items row for a missing order fails a FOREIGN KEY', function () {
  this.observe('order_items.order_id FK', () => fails(this.tmp, 'INSERT INTO order_items (order_id, product_id, qty, price_cents) VALUES (999, 1, 1, 1)', [], /FOREIGN KEY constraint failed/));
});
Then('inserting an order_items row for a missing product fails a FOREIGN KEY', function () {
  this.observe('order_items.product_id FK', () => fails(this.tmp, 'INSERT INTO order_items (order_id, product_id, qty, price_cents) VALUES (1, 999, 1, 1)', [], /FOREIGN KEY constraint failed/));
});
Then('inserting a product with negative price fails a CHECK', function () {
  this.observe('price_cents >= 0', () => fails(this.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (4, 'N1', 'P', 1, -1, 1)", [], /CHECK constraint failed/));
});
Then('inserting a product with negative stock fails a CHECK', function () {
  this.observe('stock >= 0', () => fails(this.tmp, "INSERT INTO products (id, sku, name, category_id, price_cents, stock) VALUES (5, 'N2', 'P', 1, 1, -1)", [], /CHECK constraint failed/));
});
Then('inserting a cart item with zero quantity fails a CHECK', function () {
  this.observe('qty > 0', () => fails(this.tmp, 'INSERT INTO cart_items (cart_id, product_id, qty) VALUES (1, 1, 0)', [], /CHECK constraint failed/));
});
Then('inserting a stock movement with zero delta fails a CHECK', function () {
  this.observe('delta <> 0', () => fails(this.tmp, "INSERT INTO stock_movements (product_id, delta, reason, created_at) VALUES (1, 0, 'seed', 1)", [], /CHECK constraint failed/));
});
Then('inserting a stock movement with reason {string} fails a CHECK', function (reason) {
  this.observe('reason CHECK', () => fails(this.tmp, 'INSERT INTO stock_movements (product_id, delta, reason, created_at) VALUES (1, 1, ?, 1)', [reason], /CHECK constraint failed/));
});
Then('applying the seed again changes no row counts', function () {
  const fs = require('fs'); const path = require('path');
  this.observe('seed idempotent', () => {
    const before = ['products', 'categories', 'coupons', 'stock_movements'].map((t) => this.tmp.prepare('SELECT COUNT(*) AS n FROM ' + t).get().n);
    this.tmp.exec(fs.readFileSync(path.join(__dirname, '..', '..', '..', '..', 'services', 'mini-shop', 'db', 'seed.sql'), 'utf8'));
    const after = ['products', 'categories', 'coupons', 'stock_movements'].map((t) => this.tmp.prepare('SELECT COUNT(*) AS n FROM ' + t).get().n);
    return { passed: j(before) === j(after), detail: 'before ' + j(before) + ', after ' + j(after) };
  });
});

// ---------------------------------------------------------------- checkout ↔ rows

Then('the order total equals the sum of its line amounts', async function () {
  await check(this, 'order total == Σ line amounts', () => { const o = order(this); if (!o) return { passed: false, detail: 'no order: ' + j(this.last && this.last.body) }; const sum = o.items.reduce((s, it) => s + it.line_cents, 0); const row = this.store.get('SELECT * FROM orders WHERE id = ?', o.id); return { passed: row.total_cents === o.total_cents && (row.subtotal_cents - row.discount_cents) === row.total_cents && sum === row.subtotal_cents, detail: `rowsub ${row.subtotal_cents} disc ${row.discount_cents} total ${row.total_cents}, lines ${sum}` }; });
});
Then('each order line price equals the product\'s price at purchase', async function () {
  await check(this, 'order line price == product price', () => { const o = order(this); const bad = o.items.filter((it) => { const p = this.store.get('SELECT price_cents FROM products WHERE id = ?', it.product_id); return it.price_cents !== p.price_cents; }); return { passed: bad.length === 0, detail: bad.length ? j(bad) : o.items.length + ' lines match' }; });
});
Then('the stock of product {int} fell by {int}', async function (pid, d) {
  await check(this, `stock of ${pid} fell by ${d}`, () => { const now = this.store.get('SELECT stock FROM products WHERE id = ?', pid).stock; return { passed: this.noted['stock.' + pid] - now === d, detail: `before ${this.noted['stock.' + pid]}, now ${now}` }; });
});
Then('a stock movement of {int} for product {int} with reason {string} is linked to the order', async function (delta, pid, reason) {
  await check(this, `movement ${delta} for ${pid} linked to order`, () => { const o = order(this); const m = this.store.get('SELECT * FROM stock_movements WHERE order_id = ? AND product_id = ?', o.id, pid); return { passed: !!m && m.delta === delta && m.reason === reason, detail: m ? `delta ${m.delta}, reason ${m.reason}` : 'no movement for order ' + o.id }; });
});
Then('the sum of movements for product {int} equals its current stock', async function (pid) {
  await check(this, `ledger of ${pid} == stock`, () => { const ledger = this.store.ledgerStock(pid); const stock = this.store.get('SELECT stock FROM products WHERE id = ?', pid).stock; return { passed: ledger === stock, detail: `ledger ${ledger}, stock ${stock}` }; });
});
Then('the checkout is refused with code {string}', function (code) {
  this.observe('checkout refused: ' + code, () => ({ passed: !!(this.last && this.last.status >= 400 && this.last.body && this.last.body.code === code), detail: this.last ? this.last.status + ' ' + j(this.last.body) : 'no response' }));
});
Then('the stock of product {int} is unchanged', async function (pid) {
  await check(this, `stock of ${pid} unchanged`, () => { const now = this.store.get('SELECT stock FROM products WHERE id = ?', pid).stock; return { passed: now === this.noted['stock.' + pid], detail: `before ${this.noted['stock.' + pid]}, now ${now}` }; });
});
Then('no new order was created', async function () {
  await check(this, 'order count unchanged', () => { const n = this.store.count('orders'); return { passed: n === this.noted.orders, detail: `before ${this.noted.orders}, now ${n}` }; });
});
Then('the cart row status is {string}', async function (status) {
  await check(this, 'cart status ' + status, () => { const c = this.store.get('SELECT status FROM carts WHERE token = ?', this.cartToken); return { passed: !!c && c.status === status, detail: c ? c.status : 'no cart' }; });
});
Then('the order\'s customer is the buyer', async function () {
  await check(this, 'order.customer_id == buyer', () => { const o = order(this); const row = this.store.get('SELECT customer_id FROM orders WHERE id = ?', o.id); return { passed: row.customer_id === this.buyer.id, detail: `order ${row.customer_id}, buyer ${this.buyer.id}` }; });
});
Then('the order has {int} order lines', async function (n) {
  await check(this, `order has ${n} lines`, () => { const o = order(this); const c = this.store.count('order_items', 'WHERE order_id = ?', o.id); return { passed: c === n, detail: 'lines ' + c }; });
});
Then('the order discount is {int} percent of the subtotal', async function (pct) {
  await check(this, `discount == ${pct}% subtotal`, () => { const o = order(this); const row = this.store.get('SELECT * FROM orders WHERE id = ?', o.id); return { passed: row.discount_cents === Math.floor(row.subtotal_cents * pct / 100), detail: `subtotal ${money(row.subtotal_cents)}, discount ${money(row.discount_cents)}` }; });
});
Then('the order total is the subtotal minus the discount', async function () {
  await check(this, 'total == subtotal - discount', () => { const o = order(this); const r = this.store.get('SELECT * FROM orders WHERE id = ?', o.id); return { passed: r.total_cents === r.subtotal_cents - r.discount_cents, detail: `${r.subtotal_cents} - ${r.discount_cents} = ${r.total_cents}` }; });
});
Then('the order total equals the subtotal minus the discount on the row', async function () {
  await check(this, 'row total == subtotal - discount', () => { const o = order(this); const r = this.store.get('SELECT * FROM orders WHERE id = ?', o.id); return { passed: r.total_cents === r.subtotal_cents - r.discount_cents && r.discount_cents > 0, detail: `${r.subtotal_cents} - ${r.discount_cents} = ${r.total_cents}` }; });
});
Then('the redemption count of coupon {string} grew by {int}', async function (code, d) {
  await check(this, `redeemed of ${code} grew by ${d}`, () => { const now = this.store.get('SELECT redeemed FROM coupons WHERE code = ?', code).redeemed; return { passed: now - this.noted['redeem.' + code] === d, detail: `before ${this.noted['redeem.' + code]}, now ${now}` }; });
});
Then('exactly one new order was created', async function () {
  await check(this, 'exactly one new order', () => { const n = this.store.count('orders'); return { passed: n === this.noted.orders + 1, detail: `before ${this.noted.orders}, now ${n}` }; });
});
Then('both checkouts returned the same order id', function () {
  this.observe('idempotent replay returns same order', () => { const a = this.noted.firstOrder, b = this.noted.secondOrder; return { passed: !!(a && b && a.body && b.body && a.body.id === b.body.id), detail: a && b ? `first ${a.body && a.body.id}, second ${b.body && b.body.id}` : 'missing responses' }; });
});
Then('no order_items row references a product missing from products', async function () {
  await check(this, 'no orphan order line', () => { const n = this.store.count('order_items oi', 'WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.id = oi.product_id)'); return { passed: n === 0, detail: n + ' orphans' }; });
});
Then('no orders row references a cart missing from carts', async function () {
  await check(this, 'no orphan order->cart', () => { const n = this.store.count('orders o', 'WHERE NOT EXISTS (SELECT 1 FROM carts c WHERE c.id = o.cart_id)'); return { passed: n === 0, detail: n + ' orphans' }; });
});
Then('the order subtotal equals the sum of quantity times captured price', async function () {
  await check(this, 'subtotal == Σ qty×price', () => { const o = order(this); const r = this.store.get('SELECT subtotal_cents FROM orders WHERE id = ?', o.id); const sum = this.store.all('SELECT qty, price_cents FROM order_items WHERE order_id = ?', o.id).reduce((s, it) => s + it.qty * it.price_cents, 0); return { passed: r.subtotal_cents === sum, detail: `subtotal ${r.subtotal_cents}, Σ ${sum}` }; });
});
Then('the stock of product {int} is not negative', async function (pid) {
  await check(this, `stock of ${pid} >= 0`, () => { const s = this.store.get('SELECT stock FROM products WHERE id = ?', pid).stock; return { passed: s >= 0, detail: 'stock ' + s }; });
});
Then('a cart_items row holds {int} of product {int}', async function (qty, pid) {
  await check(this, `cart line ${qty}×${pid}`, () => { const cart = this.store.get('SELECT id FROM carts WHERE token = ?', this.cartToken); const it = cart && this.store.get('SELECT qty FROM cart_items WHERE cart_id = ? AND product_id = ?', cart.id, pid); return { passed: !!it && it.qty === qty, detail: it ? 'qty ' + it.qty : 'no cart line' }; });
});
Then('the seed movements for product {int} sum to a stock at or above its current stock', async function (pid) {
  await check(this, 'ledger >= stock for seeded product', () => { const ledger = this.store.ledgerStock(pid); const stock = this.store.get('SELECT stock FROM products WHERE id = ?', pid).stock; return { passed: ledger >= stock && ledger > 0, detail: `ledger ${ledger}, stock ${stock}` }; });
});
