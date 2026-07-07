# orders — the fact explore's base view.
# Grain: one row per order (matches fct_orders in the Snowflake project).

view: orders {
  sql_table_name: OLIST_DB.STAGING_marts.FCT_ORDERS ;;

  dimension: order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ORDER_ID ;;
  }

  dimension: customer_id {
    type: string
    hidden: yes          # join key, not an analysis field
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}.ORDER_STATUS ;;
  }

  dimension_group: ordered {
    type: time
    timeframes: [date, week, month, quarter, year, day_of_week]
    sql: ${TABLE}.ORDERED_AT ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.DELIVERED_AT ;;
  }

  dimension: was_delivered_late {
    type: yesno
    sql: ${TABLE}.WAS_DELIVERED_LATE ;;
  }

  dimension: total_revenue {
    type: number
    hidden: yes          # raw column; exposed only through measures
    sql: ${TABLE}.TOTAL_REVENUE ;;
  }

  dimension: revenue_tier {
    type: tier
    tiers: [50, 100, 200, 500]
    style: integer
    sql: ${TABLE}.TOTAL_REVENUE ;;
  }

  # ---- measures: the semantic layer's whole point. Revenue is defined
  # HERE, once; every dashboard and explore inherits the same definition.
  measure: order_count {
    type: count
    drill_fields: [order_id, ordered_date, order_status, total_gross_revenue]
  }

  measure: total_gross_revenue {
    type: sum
    sql: ${total_revenue} ;;
    value_format_name: usd
    description: "Items + freight, canceled orders excluded via the always_filter on the explore."
  }

  measure: average_order_value {
    type: number
    sql: ${total_gross_revenue} / NULLIF(${order_count}, 0) ;;
    value_format_name: usd
    description: "Recomputed from sums — never an average of per-row averages."
  }

  measure: late_delivery_rate {
    type: number
    sql: COUNT(CASE WHEN ${was_delivered_late} THEN 1 END)
         / NULLIF(${order_count}, 0) ;;
    value_format_name: percent_1
  }
}
