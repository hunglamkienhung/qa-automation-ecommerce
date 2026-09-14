'use strict';

const { When, Then } = require('@cucumber/cucumber');
const { MiniShop, ApiUnreachable } = require('../venues/minishop');
const { DbUnreachable } = require('../../db/store');

/**
 * Steps for features/be-minishop-security.feature -- adversarial probes of the
 * authentication surface. The Background, the store, and the buyer/cart Givens
 * are shared from the other @minishop steps; only the forged/tampered requests,
 * the brute-force loop, and a couple of secret-hygiene assertions are new here.
 */

const shop = new MiniShop();
const UNREACHABLE = [ApiUnreachable, DbUnreachable];
const FORGED = 'cust_forged000000000000000000';

async function send(world, method, path, opts = {}) {
  if (world.sourceError) return;
  try { world.api = await shop.request(method, path, opts); world.last = world.api; } catch (err) {
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
const bodyText = (world) => JSON.stringify((world.api && world.api.body) || {});

// ---------------------------------------------------------------- forged / tampered

When('checkout is posted with a forged token', { timeout: 30_000 }, async function () { await send(this, 'POST', '/checkout', { token: FORGED, body: { cart_token: this.cartToken } }); });
When('the buyer checks out with a token that extends their own', { timeout: 30_000 }, async function () { await send(this, 'POST', '/checkout', { token: this.buyer.token + 'x', body: { cart_token: this.cartToken } }); });
When('the order is read with a forged token', { timeout: 30_000 }, async function () { await send(this, 'GET', '/orders/' + this.last.body.id, { token: FORGED }); });

// ---------------------------------------------------------------- login: enumeration / lockout

When('a login is attempted for an unregistered email', { timeout: 30_000 }, async function () { await send(this, 'POST', '/auth/login', { body: { email: 'ghost+' + Date.now() + '@example.test', password: 'x' } }); });
When('the buyer fails to log in {int} times', { timeout: 60_000 }, async function (n) { for (let i = 0; i < n; i++) await send(this, 'POST', '/auth/login', { body: { email: this.buyer.email, password: 'definitely-wrong' } }); });

// ---------------------------------------------------------------- secret hygiene

Then('the response carries no password hash', async function () {
  await check(this, 'no password hash leaked', () => { const t = bodyText(this); const leaks = ['sha256$', 'password_hash', 'password'].filter((p) => t.includes(p)); return { passed: leaks.length === 0, detail: leaks.length ? 'leaked ' + leaks.join(',') : 'clean' }; });
});
Then('the response carries no token and no password hash', async function () {
  await check(this, 'no credential leaked', () => { const t = bodyText(this); const leaks = ['cust_', 'sha256$', 'password_hash', 'token'].filter((p) => t.includes(p)); return { passed: leaks.length === 0, detail: leaks.length ? 'leaked ' + leaks.join(',') : 'clean' }; });
});
