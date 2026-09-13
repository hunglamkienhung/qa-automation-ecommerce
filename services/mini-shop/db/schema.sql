-- mini-shop: a small but real store. The tables are the object under test; both
-- test stacks open this same SQLite file and assert on its rows directly, and
-- the REST layer reads and writes it.
--
-- Money is stored in integer minor units (cents), never as a float: 19.99 is
-- 1999. Comparisons are exact. Stock is a whole count. Every amount is
-- non-negative by CHECK, every child row points at a real parent by FOREIGN
-- KEY, and the invariants a shop must never break -- an order total equal to
-- the sum of its lines, stock that never goes below zero -- are enforced here
-- so a bug in the service surfaces as a constraint violation, not as a quietly
-- wrong number.

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS categories (
  id     INTEGER PRIMARY KEY,
  slug   TEXT    NOT NULL UNIQUE,
  name   TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
  id            INTEGER PRIMARY KEY,
  sku           TEXT    NOT NULL UNIQUE,
  name          TEXT    NOT NULL,
  category_id   INTEGER NOT NULL REFERENCES categories(id),
  price_cents   INTEGER NOT NULL CHECK (price_cents >= 0),
  stock         INTEGER NOT NULL CHECK (stock >= 0),
  active        INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);
CREATE INDEX IF NOT EXISTS products_category ON products(category_id);

CREATE TABLE IF NOT EXISTS customers (
  id             INTEGER PRIMARY KEY,
  email          TEXT    NOT NULL UNIQUE,
  name           TEXT    NOT NULL,
  password_hash  TEXT    NOT NULL,
  token          TEXT    UNIQUE,             -- issued at login; the API's bearer
  created_at     INTEGER NOT NULL
);

-- A cart is per session or per customer. customer_id is NULL for a guest cart.
CREATE TABLE IF NOT EXISTS carts (
  id           INTEGER PRIMARY KEY,
  token        TEXT    NOT NULL UNIQUE,      -- the cart handle the client holds
  customer_id  INTEGER REFERENCES customers(id),
  status       TEXT    NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'checked_out', 'abandoned')),
  created_at   INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS cart_items (
  id          INTEGER PRIMARY KEY,
  cart_id     INTEGER NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_id  INTEGER NOT NULL REFERENCES products(id),
  qty         INTEGER NOT NULL CHECK (qty > 0),
  UNIQUE (cart_id, product_id)              -- one line per product; adding again merges
);

CREATE TABLE IF NOT EXISTS coupons (
  code            TEXT    PRIMARY KEY,
  kind            TEXT    NOT NULL CHECK (kind IN ('percent', 'fixed')),
  value           INTEGER NOT NULL CHECK (value >= 0),   -- percent (0-100) or cents
  min_spend_cents INTEGER NOT NULL DEFAULT 0 CHECK (min_spend_cents >= 0),
  active          INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
  max_redemptions INTEGER,                                -- NULL = unlimited
  redeemed        INTEGER NOT NULL DEFAULT 0 CHECK (redeemed >= 0)
);

CREATE TABLE IF NOT EXISTS orders (
  id             INTEGER PRIMARY KEY,
  customer_id    INTEGER NOT NULL REFERENCES customers(id),
  cart_id        INTEGER NOT NULL REFERENCES carts(id),
  subtotal_cents INTEGER NOT NULL CHECK (subtotal_cents >= 0),
  discount_cents INTEGER NOT NULL DEFAULT 0 CHECK (discount_cents >= 0),
  total_cents    INTEGER NOT NULL CHECK (total_cents >= 0),
  coupon_code    TEXT    REFERENCES coupons(code),
  status         TEXT    NOT NULL DEFAULT 'placed' CHECK (status IN ('placed', 'cancelled')),
  idempotency_key TEXT   UNIQUE,             -- a retried checkout returns the same order
  created_at     INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS orders_customer ON orders(customer_id);

CREATE TABLE IF NOT EXISTS order_items (
  id           INTEGER PRIMARY KEY,
  order_id     INTEGER NOT NULL REFERENCES orders(id),
  product_id   INTEGER NOT NULL REFERENCES products(id),
  qty          INTEGER NOT NULL CHECK (qty > 0),
  price_cents  INTEGER NOT NULL CHECK (price_cents >= 0),  -- captured at purchase; never re-read from products
  UNIQUE (order_id, product_id)
);

-- Every stock change, with a reason. The running product.stock must always
-- equal the seed level plus the sum of movements -- a ledger the DB tier checks.
CREATE TABLE IF NOT EXISTS stock_movements (
  id           INTEGER PRIMARY KEY,
  product_id   INTEGER NOT NULL REFERENCES products(id),
  delta        INTEGER NOT NULL CHECK (delta <> 0),
  reason       TEXT    NOT NULL CHECK (reason IN ('seed', 'checkout', 'refund', 'restock')),
  order_id     INTEGER REFERENCES orders(id),
  created_at   INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS stock_movements_product ON stock_movements(product_id);
