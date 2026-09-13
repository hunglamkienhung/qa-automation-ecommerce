# qa-automation-ecommerce — docs

QA automation for an e-commerce domain: **155 cases**, one shared grading core,
and two stacks (Node + Python) that read one Gherkin set and return the **same
verdict for every case**.

→ **[The repository](https://github.com/hunglamkienhung/qa-automation-ecommerce)** ·
[README](https://github.com/hunglamkienhung/qa-automation-ecommerce#readme)

## Contents

- **[Architecture](ARCHITECTURE.md)** — one core, two stacks, and why the domain
  pairs a live read-only storefront with a self-written mini-shop that has a real
  database.
- **[Grading](GRADING.md)** — Failed > Blocked > Passed, why an outage is never
  a failure, and a gate that fails in both directions.
- **[Gherkin conventions](GHERKIN.md)** — one feature set bound in two stacks.
- **[Queue format](QUEUE-FORMAT.md)** — the append-only source of truth.
- **[Demo script](DEMO.md)** — a five-minute walkthrough, least-dependent first.

## At a glance

| Layer | Target | Cases |
|---|---|---|
| DB | mini-shop SQLite, opened directly | 30 |
| API | mini-shop REST + automationexercise public API | 65 |
| FE | mini-shop storefront + automationexercise (Playwright) | 60 |
| | **Total** | **155** |
