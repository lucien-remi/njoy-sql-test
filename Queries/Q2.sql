WITH time_range AS
  (SELECT date_trunc('hour', min(created_at)) AS min_hr,
          date_trunc('hour', max(created_at)) AS max_hr
   FROM orders),
     time_series AS
  (SELECT generate_series(min_hr, max_hr, '1 hour') AS hour
   FROM time_range),
     returning_customers AS
  (SELECT customer_id,
          count(order_id) AS order_count
   FROM public.orders
   GROUP BY 1
   HAVING count(order_id) > 1),
     question_1 AS
  (SELECT DATE_TRUNC('hour', created_at) AS hour,
          sum(total_price - total_tax) AS revenue,
          count(orders.order_id) AS orders,
          count(returning_customers.order_count) AS repeat_orders
   FROM orders
   LEFT JOIN returning_customers ON orders.customer_id = returning_customers.customer_id
   GROUP BY 1)
SELECT hour
FROM time_series
WHERE time_series.hour NOT IN
    (SELECT hour
     FROM question_1)
