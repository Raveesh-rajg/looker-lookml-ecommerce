"""Structural validation of the LookML project via the lkml parser.

Without a Looker instance, this is the CI a LookML repo can still have —
and it's the same approach real teams layer on top of Looker's own
validator (parse + conventions + referential checks).
"""

import pathlib
import sys

import lkml
import pytest

ROOT = pathlib.Path(__file__).resolve().parents[1]


def load(path):
    return lkml.load(path.read_text())


VIEW_FILES = sorted((ROOT / "views").glob("*.view.lkml"))
MODEL = load(ROOT / "models" / "ecommerce.model.lkml")


class TestParses:
    @pytest.mark.parametrize("path", VIEW_FILES, ids=lambda p: p.name)
    def test_views_parse(self, path):
        assert load(path)["views"]

    def test_model_parses(self):
        assert MODEL["explores"]


class TestConventions:
    def views(self):
        for path in VIEW_FILES:
            for v in load(path)["views"]:
                yield path.name, v

    def test_every_view_has_primary_key(self):
        for fname, v in self.views():
            pks = [d for d in v.get("dimensions", []) if d.get("primary_key") == "yes"]
            assert len(pks) == 1, f"{fname}:{v['name']} needs exactly one primary_key"

    def test_measures_are_typed_and_money_is_formatted(self):
        for fname, v in self.views():
            for m in v.get("measures", []):
                assert "type" in m, f"{fname}:{m['name']} untyped"
                if "revenue" in m["name"] or "value" in m["name"]:
                    assert m.get("value_format_name") == "usd", (
                        f"{fname}:{m['name']} money without usd format")

    def test_ratio_measures_guard_divide_by_zero(self):
        for fname, v in self.views():
            for m in v.get("measures", []):
                sql = m.get("sql", "")
                if "/" in sql:
                    assert "NULLIF" in sql.upper(), (
                        f"{fname}:{m['name']} division without NULLIF")


class TestModelIntegrity:
    def test_joins_reference_defined_views(self):
        defined = set()
        for path in VIEW_FILES:
            defined |= {v["name"] for v in load(path)["views"]}
        for explore in MODEL["explores"]:
            assert explore["name"] in defined
            for j in explore.get("joins", []):
                assert j["name"] in defined, f"join to undefined view {j['name']}"

    def test_every_join_declares_relationship(self):
        for explore in MODEL["explores"]:
            for j in explore.get("joins", []):
                assert "relationship" in j, (
                    f"{explore['name']}.{j['name']}: missing relationship "
                    "(Looker assumes many_to_one and silently fans out counts)")

    def test_orders_explore_has_governed_cancel_filter(self):
        orders = next(e for e in MODEL["explores"] if e["name"] == "orders")
        assert "always_filter" in orders
