'use strict';

/**
 * The live site's public API: automationexercise.com/api. No key, read-mostly.
 *
 * A quirk worth stating: this API answers HTTP 200 for almost everything and
 * puts the real outcome in a `responseCode` field in the JSON body -- 200, 400,
 * 405. The assertions read that field, not the HTTP status, because that is the
 * contract the API actually offers.
 *
 * A transport failure is SiteUnreachable (grades Blocked). A shape this adapter
 * did not expect is thrown as is.
 */

const BASE = (process.env.SITE_API_URL || 'https://automationexercise.com/api').replace(/\/+$/, '');
const USER_AGENT = 'qa-automation-ecommerce/1.0 (read-only invariants)';
const TIMEOUT_MS = 25_000;

class SiteUnreachable extends Error {}

async function request(method, path, form) {
  const init = { method, headers: { 'user-agent': USER_AGENT, accept: 'application/json' }, signal: AbortSignal.timeout(TIMEOUT_MS) };
  if (form) { init.headers['content-type'] = 'application/x-www-form-urlencoded'; init.body = new URLSearchParams(form).toString(); }
  let res;
  try { res = await fetch(BASE + path, init); } catch (err) {
    throw new SiteUnreachable('GET ' + path + ' -- ' + (err.cause?.code || err.name || err.message));
  }
  const text = await res.text();
  // 5xx/429/403 and Cloudflare-style challenges are the site being unavailable,
  // not the site being wrong. From some runner IPs the JSON API answers 200 with
  // an HTML challenge page; a non-JSON body is treated as unreachable, so the
  // tier grades Blocked rather than throwing on `undefined.products`.
  if (res.status >= 500 || res.status === 429 || res.status === 403) throw new SiteUnreachable(method + ' ' + path + ' -- HTTP ' + res.status);
  let body; try { body = JSON.parse(text); } catch { body = null; }
  if (body === null || typeof body !== 'object') throw new SiteUnreachable(method + ' ' + path + ' -- expected JSON, got ' + (text.slice(0, 40).replace(/\s+/g, ' ')) + '…');
  return { httpStatus: res.status, body, responseCode: body.responseCode ?? null };
}

const productsList = () => request('GET', '/productsList');
const brandsList = () => request('GET', '/brandsList');
const searchProduct = (term) => request('POST', '/searchProduct', term === undefined ? undefined : { search_product: term });
const verifyLogin = (form) => request('POST', '/verifyLogin', form);
const productsListPost = () => request('POST', '/productsList');   // method not allowed by the API
const brandsListPost = () => request('POST', '/brandsList');
const getUserByEmail = (email) => request('GET', '/getUserDetailByEmail?email=' + encodeURIComponent(email));

/** Parse "Rs. 500" into an integer number of rupees; null if it does not match. */
function parsePrice(s) {
  const m = /^Rs\.\s*(\d+)$/.exec(String(s).trim());
  return m ? Number(m[1]) : null;
}

module.exports = { BASE, SiteUnreachable, request, productsList, brandsList, searchProduct, verifyLogin, productsListPost, brandsListPost, getUserByEmail, parsePrice };
