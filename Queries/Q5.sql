WITH returning_customers AS
  (SELECT customer_id,
          count(order_id)
   FROM public.orders
   GROUP BY 1
   HAVING count(order_id) > 1),
     returning_customer_orders AS
  (SELECT orders.customer_id, orders.order_id, created_at, SUM(total_price-total_tax) revenue
   FROM orders
   INNER JOIN returning_customers ON returning_customers.customer_id=orders.customer_id
   GROUP BY 1, 2, 3),
                               recent_orders AS
  (SELECT customer_id,
          max(created_at) AS created_at
   FROM returning_customer_orders AS rco
   GROUP BY 1),
                               previous_orders AS
  (SELECT rco.customer_id, max(rco.created_at) AS created_at
   FROM returning_customer_orders rco
   LEFT JOIN recent_orders ro ON rco.customer_id=ro.customer_id
   AND rco.created_at=ro.created_at
   WHERE ro.customer_id ISNULL
   GROUP BY 1)
SELECT rco.customer_id,
       max(rco.created_at) last_order_date,
       max(rco.created_at)+(max(rco.created_at)-min(rco.created_at)) next_projected_order_date,
       avg(rco.revenue) next_projected_order_value
FROM returning_customer_orders rco
INNER JOIN recent_orders ro ON ro.customer_id=rco.customer_id
INNER JOIN previous_orders po ON po.customer_id=ro.customer_id
WHERE rco.created_at=ro.created_at
  OR rco.created_at=po.created_at
GROUP BY 1