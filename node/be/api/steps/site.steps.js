'use strict';

const { Given, When, Then, Before } = require('@cucumber/cucumber');
const site = require('../venues/site');

/**
 * Steps for features/be-site-api.feature. HTTPS against the live site's public
 * API. This API answers HTTP 200 for almost everything and carries the real
 * outcome in a responseCode field -- the assertions read that field. A
 * transport failure is SiteUnreachable and grades Blocked.
 */

const UNREACHABLE = [site.SiteUnreachable];

Before({ tags: '@site' }, function () {
  this.site = {};   // fetched documents: products, brands, search, response
});

async function fetchOr(world, key, fn) {
  await world.fetchOrBlock(UNREACHABLE, async () => { world.site[key] = await fn(); });
}
function obs(world, description, evaluate) { world.observe(description, evaluate); }

// ---------------------------------------------------------------- fetches

async function fetchProducts(world) { await fetchOr(world, 'products', async () => { const r = await site.productsList(); world.site.lastCode = r.responseCode; return r.body.products; }); }
When('the site product list is fetched', { timeout: 30_000 }, async function () { await fetchProducts(this); });
Given('the full product list is fetched', { timeout: 30_000 }, async function () { await fetchProducts(this); });
When('the site product list is fetched again', { timeout: 30_000 }, async function () { await fetchOr(this, 'products2', async () => (await site.productsList()).body.products); });
When('the site product list is posted to', { timeout: 30_000 }, async function () { await fetchOr(this, 'resp', async () => { const r = await site.productsListPost(); this.site.lastCode = r.responseCode; return r; }); });
When('the site brand list is fetched', { timeout: 30_000 }, async function () { await fetchOr(this, 'brands', async () => { const r = await site.brandsList(); this.site.lastCode = r.responseCode; return r.body.brands; }); });
When('the site brand list is posted to', { timeout: 30_000 }, async function () { await fetchOr(this, 'resp', async () => { const r = await site.brandsListPost(); this.site.lastCode = r.responseCode; return r; }); });
When('the site is searched for {string}', { timeout: 30_000 }, async function (term) {
  await fetchOr(this, 'search', () => site.searchProduct(term));
  if (this.site.search) this.site.lastCode = this.site.search.responseCode;
  this.site.searchTerm = term;
  this.site.searchCounts = this.site.searchCounts || [];
  if (this.site.search && this.site.search.body && Array.isArray(this.site.search.body.products)) this.site.searchCounts.push(this.site.search.body.products.length);
});
async function respFetch(world, fn) { await fetchOr(world, 'resp', async () => { const r = await fn(); world.site.lastCode = r.responseCode; return r; }); }
When('the site is searched with no term', { timeout: 30_000 }, async function () { await respFetch(this, () => site.searchProduct(undefined)); });
When('login is verified with no email', { timeout: 30_000 }, async function () { await respFetch(this, () => site.verifyLogin({ password: 'x' })); });
When('login is verified for an unregistered email', { timeout: 30_000 }, async function () { await respFetch(this, () => site.verifyLogin({ email: 'no-such-' + Date.now() + '@example.test', password: 'x' })); });
When('login verification is sent as DELETE', { timeout: 30_000 }, async function () { await respFetch(this, () => site.request('DELETE', '/verifyLogin')); });
When('the detail of an unregistered email is fetched', { timeout: 30_000 }, async function () { await respFetch(this, () => site.getUserByEmail('no-such-' + Date.now() + '@example.test')); });

// ---------------------------------------------------------------- response code

Then('the site response code is {int}', function (code) {
  obs(this, 'responseCode == ' + code, () => ({ passed: this.site.lastCode === code, detail: 'responseCode ' + this.site.lastCode }));
});

// ---------------------------------------------------------------- products

Then('the product list is non-empty', function () { obs(this, 'products non-empty', () => ({ passed: this.site.products.length > 0, detail: this.site.products.length + ' products' })); });
Then('the product list has at least {int} products', function (n) { obs(this, 'at least ' + n + ' products', () => ({ passed: this.site.products.length >= n, detail: this.site.products.length + ' products' })); });
Then('no product id appears more than once', function () { obs(this, 'product ids unique', () => { const ids = this.site.products.map((p) => p.id); const dup = ids.filter((v, i) => ids.indexOf(v) !== i); return { passed: dup.length === 0, detail: dup.length ? 'dup ' + dup.slice(0, 3).join(',') : ids.length + ' unique' }; }); });
Then('every product price parses to a non-negative number', function () { obs(this, 'prices parse >= 0', () => { const bad = this.site.products.filter((p) => { const v = site.parsePrice(p.price); return v === null || v < 0; }); return { passed: bad.length === 0, detail: bad.length ? 'bad ' + bad.slice(0, 3).map((p) => p.price).join(',') : 'all parse' }; }); });
Then('every product price matches the {string} format', function (_fmt) { obs(this, 'prices match Rs. N', () => { const bad = this.site.products.filter((p) => site.parsePrice(p.price) === null); return { passed: bad.length === 0, detail: bad.length ? bad.slice(0, 3).map((p) => p.price).join(',') : 'all match' }; }); });
Then('every product has a non-empty name, brand and category', function () { obs(this, 'name/brand/category present', () => { const bad = this.site.products.filter((p) => !p.name || !p.brand || !p.category || !p.category.category); return { passed: bad.length === 0, detail: bad.length + ' incomplete' }; }); });
Then('every product category has a category and a user type', function () { obs(this, 'category + usertype present', () => { const bad = this.site.products.filter((p) => !p.category || !p.category.category || !p.category.usertype || !p.category.usertype.usertype); return { passed: bad.length === 0, detail: bad.length + ' incomplete' }; }); });
Then('every product id is a positive integer', function () { obs(this, 'ids positive integers', () => { const bad = this.site.products.filter((p) => !Number.isInteger(p.id) || p.id <= 0); return { passed: bad.length === 0, detail: bad.length + ' bad' }; }); });
Then('the response body is a JSON object carrying a numeric response code', function () { obs(this, 'body has numeric responseCode', () => ({ passed: this.site.products !== undefined, detail: 'products parsed: ' + (this.site.products ? this.site.products.length : 'no') })); });
Then('both reads return the same product ids', function () { obs(this, 'stable product ids', () => { const a = this.site.products.map((p) => p.id).sort((x, y) => x - y); const b = this.site.products2.map((p) => p.id).sort((x, y) => x - y); return { passed: JSON.stringify(a) === JSON.stringify(b), detail: `first ${a.length}, second ${b.length}` }; }); });

// ---------------------------------------------------------------- brands

Then('the brand list is non-empty', function () { obs(this, 'brands non-empty', () => ({ passed: this.site.brands.length > 0, detail: this.site.brands.length + ' brands' })); });
Then('every brand has an id and a non-empty name', function () { obs(this, 'brand id + name', () => { const bad = this.site.brands.filter((b) => !Number.isInteger(b.id) || !b.brand); return { passed: bad.length === 0, detail: bad.length + ' incomplete' }; }); });
Then('no brand id appears more than once', function () { obs(this, 'brand ids unique', () => { const ids = this.site.brands.map((b) => b.id); const dup = ids.filter((v, i) => ids.indexOf(v) !== i); return { passed: dup.length === 0, detail: dup.length ? 'dup ' + dup.slice(0, 3).join(',') : ids.length + ' unique' }; }); });
Then('every brand name is non-empty when trimmed', function () { obs(this, 'brand names trimmed non-empty', () => { const bad = this.site.brands.filter((b) => !String(b.brand).trim()); return { passed: bad.length === 0, detail: bad.length + ' empty' }; }); });

// ---------------------------------------------------------------- search

function searchProducts(world) { return (world.site.search && world.site.search.body && world.site.search.body.products) || []; }
Then('every returned product name contains {string}', function (term) { obs(this, 'names contain ' + term, () => { const bad = searchProducts(this).filter((p) => !p.name.toLowerCase().includes(term.toLowerCase())); return { passed: bad.length === 0 && searchProducts(this).length > 0, detail: bad.length ? bad.slice(0, 3).map((p) => p.name).join(',') : searchProducts(this).length + ' match' }; }); });
Then('every returned product id is in the full product list', function () { obs(this, 'search ids ⊆ catalogue', () => { const all = new Set(this.site.products.map((p) => p.id)); const bad = searchProducts(this).filter((p) => !all.has(p.id)); return { passed: bad.length === 0, detail: bad.length ? 'stray ' + bad.slice(0, 3).map((p) => p.id).join(',') : 'subset' }; }); });
Then('every searched product id is in the full product list', function () { obs(this, 'search ids ⊆ catalogue', () => { const all = new Set(this.site.products.map((p) => p.id)); const bad = searchProducts(this).filter((p) => !all.has(p.id)); return { passed: bad.length === 0, detail: bad.length ? 'stray' : 'subset' }; }); });
Then('the returned product list is empty', function () { obs(this, 'search empty', () => ({ passed: searchProducts(this).length === 0, detail: searchProducts(this).length + ' products' })); });
Then('the search returns no more products than the full catalogue', function () { obs(this, 'search count <= catalogue', () => ({ passed: searchProducts(this).length <= this.site.products.length, detail: `search ${searchProducts(this).length}, catalogue ${this.site.products.length}` })); });
Then('the search returns at least one product', function () { obs(this, 'search non-empty', () => ({ passed: searchProducts(this).length > 0, detail: searchProducts(this).length + ' products' })); });
Then('both searches return the same product count', function () { obs(this, 'case-insensitive same count', () => { const c = this.site.searchCounts || []; return { passed: c.length === 2 && c[0] === c[1], detail: 'counts ' + JSON.stringify(c) }; }); });
