'use strict';

/**
 * HTTP client for the mini-shop service. Node's built-in fetch; no library.
 *
 * A response is returned whole -- status, lower-cased headers, parsed body --
 * so a step can assert on any of them. Only a transport failure is
 * ApiUnreachable (grades Blocked); a 4xx/5xx is an answer, often the one
 * under test.
 */

const BASE = (process.env.MINI_SHOP_URL || 'http://127.0.0.1:8090').replace(/\/+$/, '');

class ApiUnreachable extends Error {}

class MiniShop {
  constructor(base = BASE) { this.base = base; }

  async request(method, path, { token, body, headers = {} } = {}) {
    const h = { ...headers };
    if (token) h.authorization = 'Bearer ' + token;
    const init = { method, headers: h };
    if (body !== undefined) { h['content-type'] = 'application/json'; init.body = JSON.stringify(body); }
    let res;
    try { res = await fetch(this.base + path, init); } catch (err) {
      throw new ApiUnreachable('mini-shop at ' + this.base + ' did not answer ' + method + ' ' + path + ': ' + (err.cause && err.cause.message ? err.cause.message : err.message));
    }
    const text = await res.text();
    let parsed = null; try { parsed = text ? JSON.parse(text) : null; } catch { parsed = null; }
    return { status: res.status, headers: Object.fromEntries([...res.headers.entries()].map(([k, v]) => [k.toLowerCase(), v])), body: parsed, text };
  }
  get(p, o) { return this.request('GET', p, o); }
  post(p, body, o = {}) { return this.request('POST', p, { ...o, body }); }
  patch(p, body, o = {}) { return this.request('PATCH', p, { ...o, body }); }
  del(p, o) { return this.request('DELETE', p, o); }

  /** Register a fresh customer with a unique email; returns { id, email, token }. */
  async register(name = 'Test Buyer') {
    const email = 'buyer+' + Date.now() + Math.random().toString(36).slice(2, 8) + '@example.test';
    const r = await this.post('/auth/register', { email, name, password: 'pw-secret-123' });
    if (r.status !== 201) throw new Error('register failed: HTTP ' + r.status + ' ' + r.text);
    return { ...r.body, password: 'pw-secret-123' };
  }
  async openCart() {
    const r = await this.post('/cart', undefined);
    if (r.status !== 201) throw new Error('open cart failed: HTTP ' + r.status + ' ' + r.text);
    return r.body.token;
  }
  async addItem(cartToken, productId, qty) { return this.post(`/cart/${cartToken}/items`, { product_id: productId, qty }); }
  async checkout(token, body) { return this.post('/checkout', body, { token }); }
}

module.exports = { MiniShop, ApiUnreachable, BASE };
