# Architecture

## Shape

```
core/                         one grading/queue/report/bugflow core
  node/  python/              same architecture, one per stack
services/
  mini-shop/                  SQLite + REST + HTML — an object of test
features/*.feature            one Gherkin set, shared by both stacks
fixtures/                     testcases.json (IDs) · expected-results.json (shape)
node/   python/               the two stacks: be/{db,api} fe/ui
testcases/                    catalogue generated from the features
scripts/                      the exact commands CI runs
```

Dependency direction is one way: `the domain → core`. The core knows nothing
about the domain. The domain links the core without publishing it — Node via
`"@portfolio/core": "file:../core/node"`, Python via `pip install -e ../core/python`.

## Why a real system next to a real third party

Reading a live storefront proves you can measure the real world; it cannot prove
you can test a **write** path, because you cannot safely mutate someone else's
database. So the domain pairs a live read-only system with a self-written one you
fully control:

```
automationexercise (read)  +  mini-shop (read/write, own DB)
```

The self-written mini-shop is where checkout decrements stock and rolls back on
oversell, where a coupon is redeemed at most once, where the ledger balances. The
live site is where invariants are checked against something nobody here can tune
to pass.

## Data flows the tests follow

```
HTTP --> mini-shop --> SQLite
         the DB tier reads the SQLite directly; the API tier checks each
         response against it; the FE tier checks the screen against both.
```

Each cross-check compares exactly one pair, so a divergence names one layer:
DB ↔ API is the REST layer; screen ↔ API is the FE.

## One feature set, two stacks

A feature file is authored once. Cucumber (Node) and pytest-bdd (Python) each
bind their own step definitions to it and file results to their own queue under
the same immutable case IDs. The gate then requires the two queues to agree.
This is the project's central claim made mechanical: the same specification,
executed two independent ways, lands on the same verdict — or the build stops.

See [GRADING.md](GRADING.md) for how a verdict is decided and
[GHERKIN.md](GHERKIN.md) for the feature conventions.
