WITH returning_customers AS
  (SELECT customer_id,
          count(order_id) AS order_count
   FROM public.orders
   GROUP BY 1
   HAVING count(order_id) > 1)
SELECT DATE_TRUNC('hour', created_at) AS hour,
       sum(total_price - total_tax) AS revenue,
       count(orders.order_id) AS orders,
       count(returning_customers.order_count) AS repeat_orders
FROM public.orders AS orders
LEFT JOIN returning_customers ON orders.customer_id = returning_customers.customer_id
GROUP BY 1
