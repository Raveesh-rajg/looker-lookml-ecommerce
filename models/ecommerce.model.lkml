# ecommerce model — connection, caching policy, and the explores.

connection: "snowflake_olist"

include: "/views/*.view.lkml"

datagroup: nightly_etl {
  sql_trigger: SELECT MAX(ORDERED_AT) FROM OLIST_DB.STAGING_marts.FCT_ORDERS ;;
  max_cache_age: "24 hours"
  description: "Invalidate caches and rebuild PDTs when new orders land."
}

persist_with: nightly_etl

explore: orders {
  label: "Orders & Revenue"
  description: "Order-grain analysis. Canceled orders are excluded by default and re-includable deliberately."

  # governed default: revenue metrics exclude canceled orders EVERYWHERE,
  # but analysts can override consciously (always_filter, not sql_always_where,
  # exactly so the exclusion is visible and changeable in the UI)
  always_filter: {
    filters: [orders.order_status: "-canceled"]
  }

  join: customers {
    type: left_outer
    relationship: many_to_one          # many orders -> one customer
    sql_on: ${orders.customer_id} = ${customers.customer_id} ;;
  }

  join: customer_order_facts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.customer_id} = ${customer_order_facts.customer_id} ;;
  }
}

explore: customers {
  label: "Customer Base"
  join: customer_order_facts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${customers.customer_id} = ${customer_order_facts.customer_id} ;;
  }
}
