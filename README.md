# Governed E-commerce Semantic Layer

Expose delivered-order revenue and stable customer lifetime value from the Olist dbt marts through LookML.

## Implementation and validation

15 local parser and warehouse-contract tests pass. Snowflake connectivity, Looker SQL generation, dashboard rendering and cache behavior require a live Looker instance.

Automated checks: **15 tests**. The GitHub Actions run linked above the file browser is the current CI result. Local checks and external integrations are separate claims.

## Reproduce locally

Use Python 3.12. Run from this repository’s root in a fresh virtual environment.

```sh
python -m venv .venv
# Activate .venv for your shell, then:
python -m pip install -r requirements.txt
```

For repositories using `src/`, set the import path before running commands:

```powershell
# PowerShell
$env:PYTHONPATH="src"
```
```sh
# macOS/Linux
export PYTHONPATH=src
```

```sh
python -m pytest tests -q
```

## Data and interpretation

The column contract is taken from dbt-snowflake-ecommerce commit 8ce2e7f. Monetary measures are BRL, not USD. customer_unique_id identifies a person across orders.

## Inspect the work

- [`tests/`](tests/) — executable checks and examples.
- [`docs/`](docs/) — methodology, integration specifications and the historical design.
- [Portfolio](https://raveesh-rajg.github.io/) — project directory.

## Completion boundary

Passing local tests establishes the checks listed in this repository. It does not establish cloud deployment, real-data quality, production security, or native BI rendering unless an explicit verification record says so.

## Connect Looker

Import the repository into a Looker project. Set `connection` in `models/ecommerce.model.lkml` to your Snowflake connection. Set `warehouse_database` and `marts_schema` in `manifest.lkml`; run Looker validation before deploying. The schema must contain the matching dbt marts. No Looker instance URL has been supplied.
