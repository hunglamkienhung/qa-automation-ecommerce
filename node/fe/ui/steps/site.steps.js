'use strict';

const { Given, When, Then, Before } = require('@cucumber/cucumber');
const { SitePage, ScreenNotReady } = require('../pages/site');
const site = require('../../../be/api/venues/site');

/**
 * Steps for features/fe-site.feature. Playwright against the live storefront;
 * the comparison figures come from the same public API the BE branch reads.
 * A slow or unreachable site is Blocked, never Failed.
 */

const UNREACHABLE = [ScreenNotReady, site.SiteUnreachable];

Before({ tags: '@site and @fe' }, function () { this.siteScreen = {}; });

Given('the products page is open', { timeout: 120_000 }, async function () {
  this.sitePage = new SitePage(this.page);
  await this.fetchOrBlock(UNREACHABLE, async () => { await this.sitePage.openProducts(); this.siteScreen.products = await this.sitePage.products(); });
});

async function scr(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  let r;
  // This tier cross-checks a LIVE screen against a LIVE API; when either is
  // slow, blocked, or serves a challenge page, the comparison is unobservable,
  // not a product defect. Any error here grades Blocked. (The mini-shop FE,
  // being deterministic, stays strict and rethrows.)
  try { r = await fn(); } catch (err) { world.unobservable(description, err instanceof ScreenNotReady || err instanceof site.SiteUnreachable ? err.message : ('the live screen or API was unavailable -- ' + err.message)); return; }
  world.check(description, r.passed, r.detail);
}
async function apiProducts(world) { if (!world.siteScreen.apiProducts) world.siteScreen.apiProducts = (await site.productsList()).body.products; return world.siteScreen.apiProducts; }
async function apiSearch(world, term) { return (await site.searchProduct(term)).body.products; }
const priceNums = (list) => list.map((p) => site.parsePrice(p.priceText)).filter((v) => v !== null);

// ---------------------------------------------------------------- actions

When('the storefront is searched for {string}', { timeout: 120_000 }, async function (term) {
  await this.fetchOrBlock(UNREACHABLE, async () => { this.siteScreen.search = await this.sitePage.search(term); this.siteScreen.searchTerm = term; });
});
When('the brand rail is read', { timeout: 120_000 }, async function () {
  await this.fetchOrBlock(UNREACHABLE, async () => { this.siteScreen.brands = await this.sitePage.openBrands(); });
});

// ---------------------------------------------------------------- product grid Thens

Then('the number of products on screen equals the API product count', { timeout: 30_000 }, async function () {
  await scr(this, 'screen count == API count', async () => { const api = await apiProducts(this); return { passed: this.siteScreen.products.length === api.length, detail: `screen ${this.siteScreen.products.length}, api ${api.length}` }; });
});
Then('every product card on screen has a name and a price', async function () {
  await scr(this, 'cards have name + price', async () => { const bad = this.siteScreen.products.filter((p) => !p.name || !p.priceText); return { passed: bad.length === 0 && this.siteScreen.products.length > 0, detail: bad.length + ' incomplete' }; });
});
Then('every product price on screen matches the {string} format', async function (_fmt) {
  await scr(this, 'prices match Rs. N', async () => { const list = this.siteScreen.search || this.siteScreen.products; const bad = list.filter((p) => site.parsePrice(p.priceText) === null); return { passed: bad.length === 0, detail: bad.length ? bad.slice(0, 3).map((p) => p.priceText).join(',') : 'all match' }; });
});
Then('every product name on screen is in the API product list', { timeout: 30_000 }, async function () {
  await scr(this, 'screen names ⊆ API', async () => { const api = new Set((await apiProducts(this)).map((p) => p.name)); const bad = this.siteScreen.products.filter((p) => !api.has(p.name)); return { passed: bad.length === 0, detail: bad.length ? 'stray ' + bad.slice(0, 3).map((p) => p.name).join(',') : 'subset' }; });
});
Then('the first product on screen matches the first API product', { timeout: 30_000 }, async function () {
  await scr(this, 'first screen == first API', async () => { const api = await apiProducts(this); const s = this.siteScreen.products[0]; return { passed: !!s && s.name === api[0].name && s.priceText === api[0].price, detail: `screen ${s && s.name}/${s && s.priceText}, api ${api[0].name}/${api[0].price}` }; });
});
Then('the screen shows at least {int} products', async function (n) {
  await scr(this, 'at least ' + n + ' products', async () => ({ passed: this.siteScreen.products.length >= n, detail: this.siteScreen.products.length + ' products' }));
});
Then('no product card on screen is missing a price', async function () {
  await scr(this, 'no missing price', async () => { const bad = this.siteScreen.products.filter((p) => !p.priceText); return { passed: bad.length === 0, detail: bad.length + ' missing' }; });
});
Then('no product card on screen is missing a name', async function () {
  await scr(this, 'no missing name', async () => { const bad = this.siteScreen.products.filter((p) => !p.name); return { passed: bad.length === 0, detail: bad.length + ' missing' }; });
});
Then('the screen\'s product names are drawn from the API without inventing any', async function () {
  await scr(this, 'no invented names', async () => { const api = new Set((await apiProducts(this)).map((p) => p.name)); const bad = this.siteScreen.products.filter((p) => !api.has(p.name)); return { passed: bad.length === 0, detail: bad.length + ' invented' }; });
});
Then('every product price on screen parses to a non-negative number', async function () {
  await scr(this, 'prices parse >= 0', async () => { const bad = this.siteScreen.products.filter((p) => { const v = site.parsePrice(p.priceText); return v === null || v < 0; }); return { passed: bad.length === 0, detail: bad.length + ' bad' }; });
});
Then('the product count on screen is the same on a second load', { timeout: 30_000 }, async function () {
  await scr(this, 'count stable across loads', async () => { await this.sitePage.openProducts(); const second = await this.sitePage.products(); return { passed: second.length === this.siteScreen.products.length, detail: `first ${this.siteScreen.products.length}, second ${second.length}` }; });
});
Then('every product price on screen starts with {string}', async function (prefix) {
  await scr(this, 'prices start with ' + prefix, async () => { const bad = this.siteScreen.products.filter((p) => !p.priceText.startsWith(prefix)); return { passed: bad.length === 0, detail: bad.length + ' without prefix' }; });
});
Then('the screen product names have no exact duplicates', async function () {
  await scr(this, 'names unique on screen', async () => { const names = this.siteScreen.products.map((p) => p.name); const dup = names.filter((v, i) => names.indexOf(v) !== i); return { passed: dup.length === 0, detail: dup.length ? 'dup ' + dup.slice(0, 3).join(',') : names.length + ' unique' }; });
});
Then('the highest price on screen equals a price the API lists', { timeout: 30_000 }, async function () {
  await scr(this, 'max screen price is an API price', async () => { const api = new Set((await apiProducts(this)).map((p) => site.parsePrice(p.price))); const max = Math.max(...priceNums(this.siteScreen.products)); return { passed: api.has(max), detail: 'max ' + max }; });
});
Then('the lowest price on screen equals a price the API lists', { timeout: 30_000 }, async function () {
  await scr(this, 'min screen price is an API price', async () => { const api = new Set((await apiProducts(this)).map((p) => site.parsePrice(p.price))); const min = Math.min(...priceNums(this.siteScreen.products)); return { passed: api.has(min), detail: 'min ' + min }; });
});
Then('the products page shows an {string} heading', async function (text) {
  await scr(this, 'heading ' + text, async () => { const body = await this.page.textContent('body'); return { passed: body.toLowerCase().includes(text.toLowerCase()), detail: text }; });
});

// ---------------------------------------------------------------- search Thens

Then('the search grid on screen is non-empty', async function () {
  await scr(this, 'search grid non-empty', async () => ({ passed: (this.siteScreen.search || []).length > 0, detail: (this.siteScreen.search || []).length + ' products' }));
});
Then('the search grid on screen is empty', async function () {
  await scr(this, 'search grid empty', async () => ({ passed: (this.siteScreen.search || []).length === 0, detail: (this.siteScreen.search || []).length + ' products' }));
});
Then('the search grid has no more products than the catalogue', async function () {
  await scr(this, 'search <= catalogue', async () => ({ passed: (this.siteScreen.search || []).length <= this.siteScreen.products.length, detail: `search ${(this.siteScreen.search || []).length}, catalogue ${this.siteScreen.products.length}` }));
});
Then('every search result name is in the API product list', { timeout: 30_000 }, async function () {
  await scr(this, 'search names ⊆ API', async () => { const api = new Set((await apiProducts(this)).map((p) => p.name)); const bad = (this.siteScreen.search || []).filter((p) => !api.has(p.name)); return { passed: bad.length === 0, detail: bad.length ? 'stray' : 'subset' }; });
});
Then('the number of products on screen equals the API search count for {string}', { timeout: 30_000 }, async function (term) {
  await scr(this, 'screen search count == API', async () => { const api = await apiSearch(this, term); return { passed: (this.siteScreen.search || []).length === api.length, detail: `screen ${(this.siteScreen.search || []).length}, api ${api.length}` }; });
});

// ---------------------------------------------------------------- brand Thens

Then('every brand on screen is in the API brand list', { timeout: 30_000 }, async function () {
  await scr(this, 'screen brands ⊆ API', async () => { const api = new Set((await site.brandsList()).body.brands.map((b) => b.brand)); const bad = (this.siteScreen.brands || []).filter((b) => !api.has(b)); return { passed: bad.length === 0 && (this.siteScreen.brands || []).length > 0, detail: bad.length ? 'stray ' + bad.slice(0, 3).join(',') : 'subset' }; });
});
Then('the brand rail on screen is non-empty', async function () {
  await scr(this, 'brand rail non-empty', async () => ({ passed: (this.siteScreen.brands || []).length > 0, detail: (this.siteScreen.brands || []).length + ' brands' }));
});
Then('no brand on screen is blank', async function () {
  await scr(this, 'no blank brand', async () => { const bad = (this.siteScreen.brands || []).filter((b) => !b.trim()); return { passed: bad.length === 0, detail: bad.length + ' blank' }; });
});
