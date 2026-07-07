# customer_order_facts — NATIVE DERIVED TABLE: per-customer rollups derived
# from the orders explore itself, so the definitions can never drift from
# the base measures. Persisted nightly: it powers cohort-style analysis
# where per-query recomputation is waste.

view: customer_order_facts {
  derived_table: {
    explore_source: orders {
      column: customer_id { field: orders.customer_id }
      column: lifetime_orders { field: orders.order_count }
      column: lifetime_revenue { field: orders.total_gross_revenue }
      column: first_order { field: orders.ordered_date }
      derived_column: is_repeat_customer {
        sql: lifetime_orders > 1 ;;
      }
    }
    datagroup_trigger: nightly_etl
  }

  dimension: customer_id {
    primary_key: yes
    type: string
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: lifetime_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${TABLE}.is_repeat_customer ;;
  }

  measure: repeat_customer_rate {
    type: number
    sql: COUNT(CASE WHEN ${is_repeat_customer} THEN 1 END)
         / NULLIF(COUNT(*), 0) ;;
    value_format_name: percent_1
  }
}
