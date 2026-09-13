-- Deterministic seed. Idempotent: INSERT OR IGNORE by primary key, so applying
-- it twice leaves exactly the same rows. Prices are in cents; a "seed" stock
-- movement mirrors each starting stock so the ledger balances from block zero.

INSERT OR IGNORE INTO categories (id, slug, name) VALUES
  (1, 'tops',   'Tops'),
  (2, 'shoes',  'Shoes'),
  (3, 'bags',   'Bags');

INSERT OR IGNORE INTO products (id, sku, name, category_id, price_cents, stock, active) VALUES
  (1, 'TOP-001', 'Cotton Tee',        1, 1999, 50, 1),
  (2, 'TOP-002', 'Linen Shirt',       1, 4950, 20, 1),
  (3, 'TOP-003', 'Wool Sweater',      1, 8900,  8, 1),
  (4, 'SHO-001', 'Canvas Sneaker',    2, 6500, 15, 1),
  (5, 'SHO-002', 'Leather Boot',      2, 14900, 5, 1),
  (6, 'SHO-003', 'Running Shoe',      2, 9900,  0, 1),   -- out of stock on purpose
  (7, 'BAG-001', 'Tote Bag',          3, 3500, 30, 1),
  (8, 'BAG-002', 'Backpack',          3, 7200, 12, 1),
  (9, 'BAG-003', 'Discontinued Clutch',3, 2500, 4, 0);   -- inactive on purpose

INSERT OR IGNORE INTO stock_movements (id, product_id, delta, reason, order_id, created_at) VALUES
  (1, 1, 50, 'seed', NULL, 1700000000),
  (2, 2, 20, 'seed', NULL, 1700000000),
  (3, 3,  8, 'seed', NULL, 1700000000),
  (4, 4, 15, 'seed', NULL, 1700000000),
  (5, 5,  5, 'seed', NULL, 1700000000),
  (7, 7, 30, 'seed', NULL, 1700000000),
  (8, 8, 12, 'seed', NULL, 1700000000),
  (9, 9,  4, 'seed', NULL, 1700000000);
  -- product 6 seeds at 0 stock: no movement.

INSERT OR IGNORE INTO coupons (code, kind, value, min_spend_cents, active, max_redemptions, redeemed) VALUES
  ('SAVE10',   'percent', 10,     0, 1, NULL, 0),
  ('TENOFF',   'fixed',   1000, 5000, 1, NULL, 0),   -- $10 off orders over $50
  ('ONCE',     'fixed',    500,    0, 1, 1,    0),   -- single redemption
  ('EXPIRED',  'percent', 20,      0, 0, NULL, 0);   -- inactive
