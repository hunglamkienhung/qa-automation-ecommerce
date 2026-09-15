# qa-automation-ecommerce

![Pytest-BDD](https://img.shields.io/badge/Pytest--BDD-tests-0A9EDC?logo=pytest&logoColor=white)
![Cucumber](https://img.shields.io/badge/Cucumber-BDD-23D96C?logo=cucumber&logoColor=white)
![Playwright](https://img.shields.io/badge/Playwright-E2E-2EAD33?logo=playwright&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-store-003B57?logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Node](https://img.shields.io/badge/Node-24-5FA04E?logo=nodedotjs&logoColor=white)
[![CI](https://github.com/hunglamkienhung/qa-automation-ecommerce/actions/workflows/ci.yml/badge.svg)](https://github.com/hunglamkienhung/qa-automation-ecommerce/actions/workflows/ci.yml)

QA automation for an e-commerce domain, built as a working system rather than a
slideshow. One shopping domain tested at **every layer it has** — database, API,
and screen — by **two independent stacks** (Node with Cucumber, Python with
pytest-bdd) that read **one** shared set of Gherkin features and must return the
**same verdict for every case**.

Nothing here needs an account, a key, or a paid service. Clone it and it runs.

[Tiếng Việt](README.vi.md) · [Architecture](docs/ARCHITECTURE.md) ·
[Grading](docs/GRADING.md) · [Gherkin](docs/GHERKIN.md) · [Demo script](docs/DEMO.md)

## The two systems under test

| System | Access | What it is |
|---|---|---|
| **mini-shop** | read + write, real DB | A small store in `services/mini-shop`: one SQLite file, Node standard library only, a REST API, and small labelled HTML pages for Playwright. |
| **automationexercise.com** | read-only, live | A live storefront with a public API — the real world, which nobody here can tune to pass. |

**1000 cases**, each with an immutable ID, run in **both** stacks and reconciled
case-by-case. Every layer the shop has is tested at that layer:

| Layer | Target | Cases | Where |
|---|---|---|---|
| DB | mini-shop SQLite, opened directly | 30 | `be/db` |
| API | mini-shop REST over that SQLite | 870 | `be/api` |
| API | mini-shop authentication boundaries (security) | 10 | `be/api` |
| API | automationexercise public API | 30 | `be/api` |
| FE | mini-shop storefront (Playwright) | 30 | `fe/ui` |
| FE | automationexercise storefront (Playwright) | 30 | `fe/ui` |
| | **Total** | **1000** | |

The **security tier** probes the auth surface like an attacker: a forged or
tampered bearer token is refused (401); a brute-force login **locks the account**
(five failures → 429, refused even with the right password); the login reveals
nothing about whether an email exists (one `bad_credentials` shape either way);
and no response ever carries a password hash. The lockout is a real control the
service now enforces, added alongside the tests that prove it.

`mini-shop` is where the **write** paths live: checkout is one transaction that
re-reads stock, refuses to oversell, captures the price at purchase, decrements
stock with a matching ledger movement, redeems a coupon at most once, and is
idempotent by key. The schema enforces what a shop must not break — unique SKUs,
order lines that reference real orders and products, non-negative money and
stock. The live site is where those same shapes are checked against something
outside this repo's control.

## The two ideas worth a minute

**One Gherkin set, two stacks, one verdict.** `features/*.feature` are shared.
`node/` runs them with Cucumber; `python/` runs the same files with pytest-bdd.
A per-case disagreement is itself a finding — the grading logic is being read
differently in two places — and the build fails on it.

**Failed > Blocked > Passed, and an outage is never a failure.** A case is
Failed only when an observed proposition is wrong. When the live source (the
site, a down service) cannot be reached, the case is **Blocked**, never Failed —
so a flaky network can never masquerade as a broken store. The CI gate checks
the *shape* of a run against `fixtures/expected-results.json`: it fails both when
a Passed turns Failed (a regression) and when a Failed turns Passed (a check that
stopped checking). See [docs/GRADING.md](docs/GRADING.md).

## Run in 30 seconds

The fastest thing that proves the machinery, needing nothing external:

```bash
# the shared grading core, both stacks
cd core/node && node --test "selftest/*.test.js"
cd ../python && pip install -e . && python -m pytest selftest -q
```

## Run the whole suite

Each step below is exactly what CI runs (`scripts/*.sh`), so it works by hand too.

```bash
# backend, one stack, no browser (seed the mini-shop, then DB + API + live site)
bash scripts/run-be.sh node       # or: python

# the storefronts (installs a chromium browser)
bash scripts/run-fe.sh node       # or: python

# the whole suite, then verify the run's shape against the baseline
bash scripts/gate.sh node
```

By hand, one tier at a time:

```bash
( cd services/mini-shop && bash serve.sh up )    # fresh seeded store
cd node && QA_DOMAIN_ROOT=.. npx cucumber-js --tags "@be and @minishop"
```

Prerequisites: Node ≥ 22.13 (for `node:sqlite`) and Python ≥ 3.11. The FE
scripts install their own browser. A devcontainer with all of it is in
[.devcontainer/](.devcontainer/devcontainer.json).

## Layout

```
core/            one grading/queue/report/bugflow core, vendored into this repo
services/
  mini-shop/     SQLite + REST + HTML — an object of test
features/        one Gherkin set, shared by both stacks
fixtures/        testcases.json (IDs) · expected-results.json (shape)
node/  python/   the two stacks: be/{db,api} fe/ui
testcases/       catalogue generated from the features (never drifts)
scripts/         the exact commands CI runs; reproducible by hand
docs/            architecture, grading rules, Gherkin conventions, demo script
.github/workflows/ci.yml
```

## Notes

- The DB tier asserts on **deltas** (note the stock, act, check what changed),
  so scenarios are independent of run order without a per-scenario reset. The
  store starts fresh each run.
- The live-site search matches across name, category and brand — so the FE and
  API tiers assert that results are a non-empty **subset** of the catalogue, not
  that a name contains the term. Measuring before asserting is the point.
- The catalogue (`fixtures/testcases.json` and `testcases/TestCases.md`) is
  generated from the feature files by `testcases/build.js`, so it can never
  drift from what actually runs.

## Honest scope

The FE tiers and the live-source API tier (automationexercise) depend on a third
party that can be slow or change its markup; those cases are written to grade
**Blocked**, not Failed, when that happens. The self-written mini-shop is fully
deterministic and is where the write paths, the database, and the harder
invariants are exercised.
