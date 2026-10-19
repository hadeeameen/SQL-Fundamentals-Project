

-- View 1 — Monthly sales


CREATE OR REPLACE VIEW monthly_sales_view AS
SELECT DATE_TRUNC('month', o.order_date)::date AS month,
       SUM(oi.quantity * oi.unit_price) AS revenue,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(
           SUM(oi.quantity * oi.unit_price)
           / COUNT(DISTINCT o.order_id), 2
       ) AS average_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY DATE_TRUNC('month', o.order_date);


-- View 2 — Customer segments


CREATE OR REPLACE VIEW customer_segments_view AS
SELECT c.customer_id,
       c.customer_name,
       c.city,
       COALESCE(
           SUM(oi.quantity * oi.unit_price)
               FILTER (WHERE o.status = 'completed'),
           0
       ) AS total_spending,
       CASE
           WHEN COALESCE(
               SUM(oi.quantity * oi.unit_price)
                   FILTER (WHERE o.status = 'completed'), 0
           ) >= 20000 THEN 'High Value'
           WHEN COALESCE(
               SUM(oi.quantity * oi.unit_price)
                   FILTER (WHERE o.status = 'completed'), 0
           ) >= 5000 THEN 'Regular'
           ELSE 'Occasional'
       END AS customer_segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city;