'use strict';

const crypto = require('crypto');

/**
 * Cross-cutting HTTP helpers: one error shape, a bearer-token lookup, a fixed
 * price formatter. Small explicit functions the routes call, so what a route
 * does is visible at the route.
 */

class ApiError extends Error {
  constructor(status, code, message, extra = {}) {
    super(message);
    this.status = status;
    this.code = code;
    this.extra = extra;
  }
}

function errorBody(err) {
  return { error: err.message, code: err.code, ...err.extra };
}

function token(prefix) {
  return prefix + '_' + crypto.randomBytes(18).toString('base64url');
}

// A weak password hash: this store holds no real accounts, and a test needs a
// deterministic transform, not security. Salted SHA-256 keeps it honest about
// never storing the plaintext.
function hashPassword(password) {
  return 'sha256$' + crypto.createHash('sha256').update('mini-shop:' + password).digest('hex');
}

module.exports = { ApiError, errorBody, token, hashPassword };
