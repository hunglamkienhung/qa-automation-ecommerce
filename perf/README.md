# Performance tests (Locust)

Load tests for the **mini-shop** service — the performance counterpart to the
functional BDD suite. They drive the same REST API under concurrency, validating
every response so a wrong status is a failure, not just a slow success.

## Run

```bash
pip install -r perf/requirements.txt
bash perf/run.sh                 # 40 users, spawn 10/s, 30s, against a fresh mini-shop
bash perf/run.sh 100 20 60s      # heavier
```

An interactive web UI (charts, live control) is available too:

```bash
( cd services/mini-shop && MINI_SHOP_DB=/tmp/mini-shop-perf/mini-shop.db bash serve.sh up )
locust -f perf/locustfile.py --host http://127.0.0.1:8090      # then open http://localhost:8089
```

## The traffic model

| Class | Weight | What it does |
|---|---|---|
| `Shopper` | 6 | Browses `/products`, a product page, `/categories`, `/search`. |
| `Buyer` | 3 | Registers, fills a cart, checks out, reads the order. |
| `CouponUser` | 1 | Applies a coupon to a subtotal (pure pricing). |

## Sold-out under load is not a failure

The mini-shop enforces stock, so under sustained load a SKU legitimately sells
out: adding it returns `409 insufficient_stock`. The `Buyer` treats that as the
correct, fast business response it is (and skips checking out an empty cart),
so the gate only trips on real errors — a 5xx or an unexpected status. The
takeaway a load run demonstrates: the store never oversells or 500s under
pressure; it rejects, correctly and quickly.

## The pass/fail gate

The locustfile's `quitting` hook exits **non-zero** when a run breaches either
threshold, so `run.sh` doubles as a CI performance gate:

- error ratio > `PERF_MAX_FAIL_RATIO` (default `0.01` — 1%)
- p95 latency > `PERF_MAX_P95_MS` (default `750` ms)

Override per environment, e.g. `PERF_MAX_P95_MS=400 bash perf/run.sh`.
