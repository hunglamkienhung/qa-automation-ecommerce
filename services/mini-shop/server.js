#!/usr/bin/env node
'use strict';

const http = require('http');
const path = require('path');
const { URL } = require('url');
const { open } = require('./lib/db');
const H = require('./lib/http');

/**
 * mini-shop: a small store over one SQLite file. Node standard library only.
 *
 * REST (JSON):
 *   GET  /products?category=&sort=&page=&limit=   list, paged
 *   GET  /products/:id
 *   GET  /categories
 *   GET  /search?q=
 *   POST /auth/register            { email, name, password }
 *   POST /auth/login               { email, password } -> { token }
 *   POST /cart                     -> { token }            (open a cart)
 *   GET  /cart/:token
 *   POST /cart/:token/items        { product_id, qty }     (add/merge)
 *   PATCH /cart/:token/items/:pid  { qty }                 (set; 0 removes)
 *   DELETE /cart/:token/items/:pid
 *   POST /coupons/apply            { code, subtotal_cents } -> { discount_cents }
 *   POST /checkout                 Bearer, { cart_token, coupon?, idempotency_key? }
 *   GET  /orders/:id               Bearer, own order only
 *
 * HTML (for Playwright): /, /product/:id, /cart/:token, /checkout/:token, /order/:id.
 *
 * The write paths that a shop must get right -- checkout decrements stock in
 * the same transaction as the order and refuses to oversell, a coupon redeems
 * at most its cap, a retried checkout is idempotent -- are all here, in
 * transactions, so the DB tier can prove them from the rows.
 */

const cfg = {
  port: Number(process.env.MINI_SHOP_PORT || 8090),
  dbFile: process.env.MINI_SHOP_DB || path.join(__dirname, 'data', 'mini-shop.db'),
  loginMaxFails: Number(process.env.MINI_SHOP_LOGIN_MAX_FAILS || 5),   // failed logins before an account is locked
  loginWindowMs: Number(process.env.MINI_SHOP_LOGIN_WINDOW_MS || 60_000),
};

const now = () => Math.floor(Date.now() / 1000);
const priceStr = (cents) => '$' + (cents / 100).toFixed(2);

function json(res, status, body, extra = {}) {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8', ...extra });
  res.end(JSON.stringify(body));
}
function html(res, status, body) {
  res.writeHead(status, { 'content-type': 'text/html; charset=utf-8' });
  res.end('<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' + body);
}
function esc(s) {
  return String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (c) => { data += c; if (data.length > 65536) reject(new H.ApiError(413, 'too_large', 'body too large')); });
    req.on('end', () => { try { resolve(data ? JSON.parse(data) : {}); } catch { reject(new H.ApiError(400, 'bad_request', 'body is not JSON')); } });
  });
}

function main() {
  const db = open(cfg.dbFile);
  // Brute-force guard: failed logins per email in a rolling window. After
  // cfg.loginMaxFails, the account is locked (429) until the window passes,
  // even for the right password; a success clears the counter. In-memory only,
  // like a small rate limiter -- it is the behaviour the security tier proves.
  const loginFails = new Map();
  function loginLocked(email) { const r = loginFails.get(email); return !!r && (Date.now() - r.first) < cfg.loginWindowMs && r.count >= cfg.loginMaxFails; }
  function noteLoginFail(email) { const r = loginFails.get(email); const fresh = !r || (Date.now() - r.first) >= cfg.loginWindowMs; const rec = fresh ? { count: 0, first: Date.now() } : r; rec.count += 1; loginFails.set(email, rec); }

  const q = {
    productsPage: db.prepare('SELECT * FROM products WHERE active = 1 AND (? IS NULL OR category_id = ?) ORDER BY CASE WHEN ? = \'price\' THEN price_cents END, CASE WHEN ? = \'name\' THEN name END, id LIMIT ? OFFSET ?'),
    productsCount: db.prepare('SELECT COUNT(*) AS n FROM products WHERE active = 1 AND (? IS NULL OR category_id = ?)'),
    product: db.prepare('SELECT * FROM products WHERE id = ?'),
    activeProduct: db.prepare('SELECT * FROM products WHERE id = ? AND active = 1'),
    categories: db.prepare('SELECT * FROM categories ORDER BY id'),
    category: db.prepare('SELECT * FROM categories WHERE id = ?'),
    search: db.prepare("SELECT * FROM products WHERE active = 1 AND name LIKE '%' || ? || '%' ORDER BY id"),
    customerByEmail: db.prepare('SELECT * FROM customers WHERE email = ?'),
    customerByToken: db.prepare('SELECT * FROM customers WHERE token = ?'),
    insCustomer: db.prepare('INSERT INTO customers (email, name, password_hash, token, created_at) VALUES (?, ?, ?, ?, ?)'),
    setToken: db.prepare('UPDATE customers SET token = ? WHERE id = ?'),
    insCart: db.prepare('INSERT INTO carts (token, customer_id, status, created_at) VALUES (?, ?, \'open\', ?)'),
    cart: db.prepare('SELECT * FROM carts WHERE token = ?'),
    cartItems: db.prepare('SELECT ci.*, p.name, p.price_cents, p.stock, p.active FROM cart_items ci JOIN products p ON p.id = ci.product_id WHERE ci.cart_id = ? ORDER BY ci.id'),
    cartItem: db.prepare('SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ?'),
    insItem: db.prepare('INSERT INTO cart_items (cart_id, product_id, qty) VALUES (?, ?, ?)'),
    setItemQty: db.prepare('UPDATE cart_items SET qty = ? WHERE cart_id = ? AND product_id = ?'),
    delItem: db.prepare('DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?'),
    coupon: db.prepare('SELECT * FROM coupons WHERE code = ?'),
    redeemCoupon: db.prepare('UPDATE coupons SET redeemed = redeemed + 1 WHERE code = ?'),
    setCartStatus: db.prepare('UPDATE carts SET status = ? WHERE id = ?'),
    insOrder: db.prepare('INSERT INTO orders (customer_id, cart_id, subtotal_cents, discount_cents, total_cents, coupon_code, status, idempotency_key, created_at) VALUES (?, ?, ?, ?, ?, ?, \'placed\', ?, ?)'),
    insOrderItem: db.prepare('INSERT INTO order_items (order_id, product_id, qty, price_cents) VALUES (?, ?, ?, ?)'),
    decStock: db.prepare('UPDATE products SET stock = stock - ? WHERE id = ?'),
    insMovement: db.prepare('INSERT INTO stock_movements (product_id, delta, reason, order_id, created_at) VALUES (?, ?, ?, ?, ?)'),
    order: db.prepare('SELECT * FROM orders WHERE id = ?'),
    orderByKey: db.prepare('SELECT * FROM orders WHERE idempotency_key = ?'),
    orderItems: db.prepare('SELECT * FROM order_items WHERE order_id = ? ORDER BY id'),
  };

  const productView = (p) => ({ id: p.id, sku: p.sku, name: p.name, category_id: p.category_id, price_cents: p.price_cents, price: priceStr(p.price_cents), stock: p.stock, in_stock: p.stock > 0 });

  function pageParams(query) {
    let limit = query.limit === undefined ? 12 : Number(query.limit);
    let page = query.page === undefined ? 1 : Number(query.page);
    if (!Number.isInteger(limit) || limit < 1 || limit > 100) throw new H.ApiError(400, 'bad_request', 'limit must be an integer between 1 and 100');
    if (!Number.isInteger(page) || page < 1) throw new H.ApiError(400, 'bad_request', 'page must be a positive integer');
    return { limit, offset: (page - 1) * limit, page };
  }

  function requireCustomer(req) {
    const m = /^Bearer\s+(\S+)$/i.exec(req.headers.authorization || '');
    if (!m) throw new H.ApiError(401, 'unauthenticated', 'a Bearer token is required');
    const c = q.customerByToken.get(m[1]);
    if (!c) throw new H.ApiError(401, 'unauthenticated', 'unknown token');
    return c;
  }

  /** Discount a subtotal by a coupon, with the same rules checkout uses. Returns cents. */
  function discountFor(coupon, subtotal) {
    if (!coupon) return { discount: 0 };
    if (!coupon.active) throw new H.ApiError(400, 'coupon_inactive', 'coupon is not active');
    if (coupon.max_redemptions !== null && coupon.redeemed >= coupon.max_redemptions) throw new H.ApiError(409, 'coupon_exhausted', 'coupon has been fully redeemed');
    if (subtotal < coupon.min_spend_cents) throw new H.ApiError(400, 'coupon_min_spend', 'order is below the coupon minimum spend', { min_spend_cents: coupon.min_spend_cents });
    const raw = coupon.kind === 'percent' ? Math.floor((subtotal * coupon.value) / 100) : coupon.value;
    return { discount: Math.min(raw, subtotal) };
  }

  async function route(req, res, url) {
    const parts = url.pathname.replace(/\/+$/, '').split('/').filter(Boolean);
    const query = Object.fromEntries(url.searchParams.entries());
    const [a, b, c, d] = parts;
    const wantsHtml = (req.headers.accept || '').includes('text/html');

    // ---- HTML pages (for Playwright) ----
    if (req.method === 'GET' && parts.length === 0) return renderCatalogue(res);
    if (req.method === 'GET' && a === 'product' && b) return renderProduct(res, b);
    if (req.method === 'GET' && a === 'cart' && b && wantsHtml) return renderCart(res, b);
    if (req.method === 'GET' && a === 'order' && b) return renderOrder(res, b);

    // ---- REST ----
    if (req.method === 'GET' && a === 'products' && !b) {
      const cat = query.category === undefined ? null : Number(query.category);
      if (cat !== null && !q.category.get(cat)) throw new H.ApiError(404, 'not_found', 'no such category');
      const sort = query.sort === undefined ? 'id' : String(query.sort);
      if (!['id', 'price', 'name'].includes(sort)) throw new H.ApiError(400, 'bad_request', 'sort must be id, price or name');
      const { limit, offset, page } = pageParams(query);
      const rows = q.productsPage.all(cat, cat, sort, sort, limit, offset);
      return json(res, 200, { total: q.productsCount.get(cat, cat).n, page, limit, products: rows.map(productView) });
    }
    if (req.method === 'GET' && a === 'products' && b) {
      const p = q.activeProduct.get(Number(b));
      if (!p) throw new H.ApiError(404, 'not_found', 'no such product');
      return json(res, 200, productView(p));
    }
    if (req.method === 'GET' && a === 'categories') return json(res, 200, { categories: q.categories.all() });
    if (req.method === 'GET' && a === 'search') {
      if (query.q === undefined || query.q === '') throw new H.ApiError(400, 'bad_request', 'q is required');
      return json(res, 200, { query: query.q, products: q.search.all(String(query.q)).map(productView) });
    }

    if (req.method === 'POST' && a === 'auth' && b === 'register') {
      const body = await readBody(req);
      if (!body.email || !body.name || !body.password) throw new H.ApiError(400, 'bad_request', 'email, name and password are required');
      if (q.customerByEmail.get(body.email)) throw new H.ApiError(409, 'email_taken', 'that email already has an account');
      const tok = H.token('cust');
      const info = q.insCustomer.run(body.email, body.name, H.hashPassword(body.password), tok, now());
      return json(res, 201, { id: Number(info.lastInsertRowid), email: body.email, token: tok });
    }
    if (req.method === 'POST' && a === 'auth' && b === 'login') {
      const body = await readBody(req);
      const email = String(body.email || '');
      if (loginLocked(email)) throw new H.ApiError(429, 'account_locked', 'too many failed logins; try again later');
      const cust = body.email ? q.customerByEmail.get(body.email) : null;
      if (!cust || cust.password_hash !== H.hashPassword(body.password || '')) { noteLoginFail(email); throw new H.ApiError(401, 'bad_credentials', 'email or password is wrong'); }
      loginFails.delete(email);   // a success clears the counter
      const tok = H.token('cust');
      q.setToken.run(tok, cust.id);
      return json(res, 200, { id: cust.id, email: cust.email, token: tok });
    }

    if (req.method === 'POST' && a === 'cart' && !b) {
      const tok = H.token('cart');
      q.insCart.run(tok, null, now());
      return json(res, 201, { token: tok, items: [], subtotal_cents: 0 });
    }
    if (a === 'cart' && b && (parts.length === 2) && req.method === 'GET') return json(res, 200, cartView(b));
    if (a === 'cart' && b && parts[2] === 'items') {
      const cart = q.cart.get(b);
      if (!cart) throw new H.ApiError(404, 'not_found', 'no such cart');
      if (cart.status !== 'open') throw new H.ApiError(409, 'cart_closed', 'cart is not open');
      if (req.method === 'POST' && parts.length === 3) {
        const body = await readBody(req);
        const pid = Number(body.product_id); const qty = Number(body.qty);
        const p = q.activeProduct.get(pid);
        if (!p) throw new H.ApiError(404, 'not_found', 'no such product');
        if (!Number.isInteger(qty) || qty < 1) throw new H.ApiError(400, 'bad_request', 'qty must be a positive integer');
        const existing = q.cartItem.get(cart.id, pid);
        const total = (existing ? existing.qty : 0) + qty;
        if (total > p.stock) throw new H.ApiError(409, 'insufficient_stock', 'not enough stock', { available: p.stock, requested: total });
        if (existing) q.setItemQty.run(total, cart.id, pid); else q.insItem.run(cart.id, pid, qty);
        return json(res, 200, cartView(b));
      }
      if (req.method === 'PATCH' && parts.length === 4) {
        const pid = Number(d); const body = await readBody(req); const qty = Number(body.qty);
        if (!Number.isInteger(qty) || qty < 0) throw new H.ApiError(400, 'bad_request', 'qty must be a non-negative integer');
        const p = q.product.get(pid);
        if (qty === 0) { q.delItem.run(cart.id, pid); return json(res, 200, cartView(b)); }
        if (!p || !p.active) throw new H.ApiError(404, 'not_found', 'no such product');
        if (qty > p.stock) throw new H.ApiError(409, 'insufficient_stock', 'not enough stock', { available: p.stock, requested: qty });
        if (!q.cartItem.get(cart.id, pid)) throw new H.ApiError(404, 'not_found', 'item not in cart');
        q.setItemQty.run(qty, cart.id, pid);
        return json(res, 200, cartView(b));
      }
      if (req.method === 'DELETE' && parts.length === 4) {
        q.delItem.run(cart.id, Number(d));
        return json(res, 200, cartView(b));
      }
    }

    if (req.method === 'POST' && a === 'coupons' && b === 'apply') {
      const body = await readBody(req);
      const coupon = q.coupon.get(String(body.code || ''));
      if (!coupon) throw new H.ApiError(404, 'not_found', 'no such coupon');
      const subtotal = Number(body.subtotal_cents);
      if (!Number.isInteger(subtotal) || subtotal < 0) throw new H.ApiError(400, 'bad_request', 'subtotal_cents must be a non-negative integer');
      const { discount } = discountFor(coupon, subtotal);
      return json(res, 200, { code: coupon.code, discount_cents: discount, total_cents: subtotal - discount });
    }

    if (req.method === 'POST' && a === 'checkout') {
      const cust = requireCustomer(req);
      const body = await readBody(req);
      return doCheckout(res, cust, body);
    }

    if (req.method === 'GET' && a === 'orders' && b) {
      const cust = requireCustomer(req);
      const o = q.order.get(Number(b));
      if (!o) throw new H.ApiError(404, 'not_found', 'no such order');
      if (o.customer_id !== cust.id) throw new H.ApiError(403, 'forbidden', 'not your order');
      return json(res, 200, orderView(o));
    }

    if (['GET', 'POST', 'PATCH', 'DELETE'].includes(req.method)) throw new H.ApiError(404, 'not_found', 'no such route');
    throw new H.ApiError(405, 'method_not_allowed', 'method not allowed');
  }

  function cartView(tokenStr) {
    const cart = q.cart.get(tokenStr);
    if (!cart) throw new H.ApiError(404, 'not_found', 'no such cart');
    const items = q.cartItems.all(cart.id);
    const subtotal = items.reduce((s, it) => s + it.qty * it.price_cents, 0);
    return { token: cart.token, status: cart.status, items: items.map((it) => ({ product_id: it.product_id, name: it.name, qty: it.qty, price_cents: it.price_cents, line_cents: it.qty * it.price_cents })), subtotal_cents: subtotal };
  }

  function orderView(o) {
    return { id: o.id, customer_id: o.customer_id, subtotal_cents: o.subtotal_cents, discount_cents: o.discount_cents, total_cents: o.total_cents, coupon_code: o.coupon_code, status: o.status, items: q.orderItems.all(o.id).map((it) => ({ product_id: it.product_id, qty: it.qty, price_cents: it.price_cents, line_cents: it.qty * it.price_cents })) };
  }

  /**
   * The heart of the shop. One transaction: re-read each line's stock, refuse
   * to oversell, write the order and its lines at the price captured now,
   * decrement stock with a matching movement, redeem the coupon, close the
   * cart. Any failure rolls the whole thing back -- no order, no stock change.
   * An idempotency key that was seen before returns the first order unchanged.
   */
  function doCheckout(res, cust, body) {
    const cart = q.cart.get(String(body.cart_token || ''));
    if (!cart) throw new H.ApiError(404, 'not_found', 'no such cart');
    const key = body.idempotency_key ? String(body.idempotency_key) : null;
    if (key) { const prior = q.orderByKey.get(key); if (prior) return json(res, 200, { ...orderView(prior), idempotent_replay: true }); }
    if (cart.status !== 'open') throw new H.ApiError(409, 'cart_closed', 'cart is not open');
    const items = q.cartItems.all(cart.id);
    if (items.length === 0) throw new H.ApiError(400, 'empty_cart', 'the cart is empty');

    const coupon = body.coupon ? q.coupon.get(String(body.coupon)) : null;
    if (body.coupon && !coupon) throw new H.ApiError(404, 'not_found', 'no such coupon');
    const subtotal = items.reduce((s, it) => s + it.qty * it.price_cents, 0);
    const { discount } = discountFor(coupon, subtotal); // validates coupon before we write anything

    db.exec('BEGIN IMMEDIATE');
    try {
      // re-read stock inside the transaction: another checkout may have moved it
      for (const it of items) {
        const fresh = q.product.get(it.product_id);
        if (!fresh || !fresh.active) throw new H.ApiError(409, 'unavailable', 'a product became unavailable', { product_id: it.product_id });
        if (fresh.stock < it.qty) throw new H.ApiError(409, 'insufficient_stock', 'not enough stock at checkout', { product_id: it.product_id, available: fresh.stock, requested: it.qty });
      }
      const info = q.insOrder.run(cust.id, cart.id, subtotal, discount, subtotal - discount, coupon ? coupon.code : null, key, now());
      const orderId = Number(info.lastInsertRowid);
      for (const it of items) {
        q.insOrderItem.run(orderId, it.product_id, it.qty, it.price_cents);
        q.decStock.run(it.qty, it.product_id);
        q.insMovement.run(it.product_id, -it.qty, 'checkout', orderId, now());
      }
      if (coupon) q.redeemCoupon.run(coupon.code);
      q.setCartStatus.run('checked_out', cart.id);
      db.exec('COMMIT');
      return json(res, 201, orderView(q.order.get(orderId)));
    } catch (err) {
      db.exec('ROLLBACK');
      throw err;
    }
  }

  // ---- HTML renderers (minimal, labelled for Playwright) ----
  function renderCatalogue(res) {
    const rows = q.productsPage.all(null, null, 'id', 'id', 100, 0).map((p) =>
      `<li class="product" data-id="${p.id}"><a href="/product/${p.id}">${esc(p.name)}</a> <span class="price">${priceStr(p.price_cents)}</span> <span class="stock">${p.stock > 0 ? 'in stock' : 'out of stock'}</span></li>`).join('');
    return html(res, 200, `<title>mini-shop</title><h1>mini-shop</h1><ul class="catalogue">${rows}</ul>`);
  }
  function renderProduct(res, id) {
    const p = q.activeProduct.get(Number(id));
    if (!p) return html(res, 404, '<title>not found</title><p>no such product</p>');
    return html(res, 200, `<title>${esc(p.name)}</title><h1 class="name">${esc(p.name)}</h1><p class="price">${priceStr(p.price_cents)}</p><p class="sku">${esc(p.sku)}</p><p class="stock">${p.stock > 0 ? 'in stock: ' + p.stock : 'out of stock'}</p>`);
  }
  function renderCart(res, tokenStr) {
    let v; try { v = cartView(tokenStr); } catch { return html(res, 404, '<title>cart</title><p>no such cart</p>'); }
    const rows = v.items.map((it) => `<li class="item" data-id="${it.product_id}">${esc(it.name)} x<span class="qty">${it.qty}</span> = <span class="line">${priceStr(it.line_cents)}</span></li>`).join('');
    return html(res, 200, `<title>cart</title><h1>cart</h1><ul class="items">${rows}</ul><p class="subtotal">${priceStr(v.subtotal_cents)}</p>`);
  }
  function renderOrder(res, id) {
    const o = q.order.get(Number(id));
    if (!o) return html(res, 404, '<title>order</title><p>no such order</p>');
    return html(res, 200, `<title>order ${o.id}</title><h1 class="order-id">Order ${o.id}</h1><p class="total">${priceStr(o.total_cents)}</p><p class="status">${esc(o.status)}</p>`);
  }

  q.category = db.prepare('SELECT * FROM categories WHERE id = ?');

  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');
    try {
      await route(req, res, url);
    } catch (err) {
      if (err instanceof H.ApiError) json(res, err.status, H.errorBody(err));
      else { console.error(err); json(res, 500, { error: 'internal error', code: 'internal' }); }
    }
  });

  server.listen(cfg.port, '127.0.0.1', () => console.error(`mini-shop on http://127.0.0.1:${cfg.port}  db ${cfg.dbFile}`));
  const shutdown = () => { server.close(); db.close(); process.exit(0); };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

if (require.main === module) main();
module.exports = { cfg };
