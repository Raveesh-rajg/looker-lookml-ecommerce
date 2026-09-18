"""Cross-repository contract, generated from the executed dbt catalog."""
import json, re
from pathlib import Path
import lkml
ROOT=Path(__file__).resolve().parents[1]
CONTRACT=json.loads((ROOT/'tests/fixtures/warehouse_columns.json').read_text())['tables']

def test_all_physical_columns_exist_in_dbt_catalog():
    for path in (ROOT/'views').glob('*.lkml'):
        for view in lkml.load(path.read_text())['views']:
            if 'sql_table_name' not in view:
                continue
            table=view['sql_table_name'].strip().split('.')[-1].lower()
            for column in re.findall(r'\$\{TABLE\}\.(\w+)',path.read_text()):
                assert column.lower() in CONTRACT[table], (table,column)

def test_customer_join_and_derived_table_use_stable_identity():
    model=(ROOT/'models/ecommerce.model.lkml').read_text()
    assert '${orders.customer_id}' not in model
    assert '${customers.customer_unique_id}' in model
    derived=(ROOT/'views/customer_order_facts.view.lkml').read_text()
    assert 'field: orders.customer_unique_id' in derived
    assert 'field: orders.ordered_date' not in derived
    assert 'field: orders.first_order_date' in derived

def test_default_filter_matches_delivered_marts():
    model=lkml.load((ROOT/'models/ecommerce.model.lkml').read_text())
    orders=next(x for x in model['explores'] if x['name']=='orders')
    assert 'delivered' in str(orders['always_filter'])

def test_missing_delivery_is_excluded_from_denominator():
    assert 'NULLIF(COUNT(${was_delivered_late}), 0)' in (ROOT/'views/orders.view.lkml').read_text()

def test_manifest_parses_and_supplies_database_and_schema():
    manifest=lkml.load((ROOT/'manifest.lkml').read_text())
    assert {c['name'] for c in manifest['constants']}=={'warehouse_database','marts_schema'}
