# customers — conformed dimension at the stable identity grain.

view: customers {
  sql_table_name: @{warehouse_database}.@{marts_schema}.DIM_CUSTOMERS ;;

  dimension: customer_unique_id {
    primary_key: yes
    type: string
    description: "Stable person-level identity; customer_id is per-order."
    sql: ${TABLE}.CUSTOMER_UNIQUE_ID ;;
  }

  dimension: customer_state {
    type: string
    map_layer_name: br_states
    sql: ${TABLE}.PRIMARY_STATE ;;
  }

  dimension: customer_city {
    type: string
    sql: ${TABLE}.PRIMARY_CITY ;;
  }

  measure: customer_count {
    type: count_distinct
    sql: ${customer_unique_id} ;;
    description: "Counts PEOPLE (unique ids), not per-order customer rows."
  }
}
