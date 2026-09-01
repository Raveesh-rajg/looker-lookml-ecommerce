# Governed LookML Semantic Layer | E-commerce warehouse

A LookML project over the Snowflake e-commerce marts (the Project-1
warehouse): two explores, three views, a native derived table with
datagroup-triggered persistence, and governed metric defaults — validated
by a **10-test structural CI** built on the `lkml` parser, because the
project was authored without a Looker instance and says so plainly.

## The access reality (read this first)

Looker (Google Cloud core) has no self-serve free tier; trials go through
sales, and instance pricing is enterprise-scale. Rather than fake
screenshots, this repo treats LookML as what it is — code — and ships the
things code can prove without a host:

- `lkml`-parsed validity for every file
- conventions enforced by tests: every view has exactly one primary key,
  money measures carry `usd` formats, every ratio guards division by zero,
  every join declares its `relationship` (the silent-fan-out killer),
  the orders explore carries its governed cancel-filter
- If/when an instance is available (employer sandbox, partner trial), the
  project deploys as-is: `connection: "snowflake_olist"` is the only
  environment binding.

## What the LookML demonstrates

- **Semantics defined once.** `total_gross_revenue`, AOV (recomputed from
  sums, never averaged averages), late-delivery rate — measures live in the
  view; every dashboard inherits them.
- **Governed defaults that stay visible.** Canceled orders are excluded via
  `always_filter` (user-visible, consciously overridable) rather than
  `sql_always_where` (invisible) — the difference is the difference between
  governance and mystery.
- **Native derived table** (`customer_order_facts`): per-customer rollups
  derived FROM the orders explore itself so definitions can't drift, and
  persisted via a `datagroup` keyed to warehouse freshness
  (`sql_trigger` on MAX(ordered_at)) rather than a dumb schedule.
- **Join hygiene**: keys hidden, `relationship` declared everywhere,
  many_to_one throughout — the fan-out discipline Looker makes explicit.

## Run the validation

```bash
pip install lkml pytest
pytest tests/ -q     # 10 tests
```

## Files

```
models/ecommerce.model.lkml    connection, datagroup, 2 explores
views/orders.view.lkml         fact view: dimension_groups, tiers, measures
views/customers.view.lkml      conformed dimension
views/customer_order_facts...  native derived table + repeat-rate measure
tests/test_lookml.py           the structural CI
```
