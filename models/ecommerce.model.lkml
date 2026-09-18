# ecommerce model — connection, caching policy, and the explores.

connection: "snowflake_olist"

include: "/views/*.view.lkml"

# Time-based invalidation also sees historical corrections in the full dbt rebuild.
datagroup: hourly_refresh {
  interval_trigger: "1 hour"
  max_cache_age: "1 hour"
}
persist_with: hourly_refresh

explore: orders {
  label: "Orders & Revenue"
  description: "Order-grain analysis. Delivered orders by default, matching the dbt marts. The visible filter can be changed deliberately."

  # Visible default matches delivered-order revenue in dbt; users can inspect or change it.
  always_filter: {
    filters: [orders.order_status: "delivered"]
  }

  join: customers {
    type: left_outer
    relationship: many_to_one          # many orders -> one customer
    sql_on: ${orders.customer_unique_id} = ${customers.customer_unique_id} ;;
  }

  join: customer_order_facts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.customer_unique_id} = ${customer_order_facts.customer_unique_id} ;;
  }
}

explore: customers {
  label: "Customer Base"
  join: customer_order_facts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${customers.customer_unique_id} = ${customer_order_facts.customer_unique_id} ;;
  }
}
