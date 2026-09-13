# Demo script (about 5 minutes)

Ordered so the earliest step needs the least to be working. Each step stands on
its own; stop wherever your time runs out.

## 1. The grading core, offline (30 seconds)

Needs nothing external. Proves the rule that everything else rests on.

```bash
cd core/node && node --test "selftest/*.test.js"
cd ../python && pip install -e . && python -m pytest selftest -q
```

Point to make: `Failed > Blocked > Passed` is asserted in both proposition
orders, and the measurement controls (a clean sample must read clean, a known-
dirty sample must be flagged) run here — the tooling is tested before it is
trusted.

## 2. One spec, two stacks, one verdict (2 minutes)

Seed the mini-shop and run the backend in each stack:

```bash
bash scripts/run-be.sh node
bash scripts/run-be.sh python
```

Point to make: both read the same `features/*.feature` and land on the same
verdict for every case. Open `*/queue/results.jsonl` in each and diff the
statuses — they match, case for case.

## 3. A real write path with a real database (1 minute)

The backend run above already exercises it; to look closely, read the SQLite
rows checkout touches:

Point to make: checkout decrements stock and writes a balanced ledger; an
oversell rolls back and leaves the store untouched; a coupon redeems exactly
once. These are asserted from the SQLite rows, not from the API's own word.

## 4. The gate that fails both ways (30 seconds)

```bash
cd node && QA_DOMAIN_ROOT=.. npx qa-verify
```

Point to make: the gate checks the *shape* of the run against
`fixtures/expected-results.json`. It catches a Passed→Failed regression **and** a
Failed→Passed check that stopped checking; no declared status is ever `Failed`
for a live-source case, so an outage cannot turn the build red.

## 5. The screens (if a browser is handy)

```bash
bash scripts/run-fe.sh node    # the mini-shop storefront + the live storefront
```

Point to make: the FE tier checks each figure on screen against the same API or
DB the BE tier reads — the frontend is held to the backend's numbers. When a
live screen is slow or down, those cases grade Blocked, never Failed.

## If nothing external is available

Step 1 stands alone, and the whole mini-shop half of the suite is deterministic:

```bash
bash scripts/run-be.sh node    # the mini-shop tiers pass; the live-site tiers Block
```

Everything live-dependent grades Blocked with a reason, and the gate stays green
because Blocked is a declared, acceptable status.
