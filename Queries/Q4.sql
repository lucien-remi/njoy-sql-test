WITH customer_types AS
  (SELECT customer_id, CASE
                           WHEN count(order_id)=1 THEN 'new_customer'
                           ELSE 'returning_customer'
                       END AS customer_type
   FROM public.orders
   GROUP BY 1)
SELECT customer_type,
       sum(total_price-total_tax) AS revenue
FROM orders
LEFT JOIN customer_types ON orders.customer_id=customer_types.customer_id
GROUP BY 1
