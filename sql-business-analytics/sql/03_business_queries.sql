-- A. Revenue analysis


-- Query 1 — Total revenue


SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2)
       AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed';


-- Query 2 — Monthly revenue


SELECT DATE_TRUNC('month', o.order_date)::date AS month,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- Query 3 — Revenue by city


SELECT c.city,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.city
ORDER BY revenue DESC;


-- Query 4 — Top-selling category by revenue


SELECT p.category,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 1;


-- Query 5 — Average order value


SELECT ROUND(
    SUM(oi.quantity * oi.unit_price)
    / COUNT(DISTINCT o.order_id), 2
) AS average_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed';


-- B. Customer analysis


-- Query 6 — Repeat customers


SELECT c.customer_id,
       c.customer_name,
       COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY order_count DESC;


-- Query 7 — Count repeat customers


SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
    HAVING COUNT(*) >= 2
) AS repeat_orders;


-- Query 8 — Top five customers by spending


SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 5;


-- Query 9 — Customer segmentation


SELECT c.customer_name,
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
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;


-- Query 10 — Customers with no completed purchases


SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'completed'
);


-- C. Product and performance analysis


-- Query 11 — Best-selling products by quantity


SELECT p.product_name,
       SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC;


-- Query 12 — Revenue by individual product


SELECT p.product_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;


-- Query 13 — Monthly revenue growth


WITH monthly_sales AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY 1
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month,
       ROUND(
           100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
           / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
           2
       ) AS growth_pct
FROM monthly_sales
ORDER BY month;


-- Query 14 — Order status breakdown


SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- Query 15 — Revenue contribution by category


WITH category_sales AS (
    SELECT p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY p.category
)
SELECT category,
       revenue,
       ROUND(
           100.0 * revenue / SUM(revenue) OVER (), 2
       ) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;


-- Query 16 — Revenue by weekday


SELECT TO_CHAR(o.order_date, 'FMDay') AS weekday,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY EXTRACT(ISODOW FROM o.order_date),
         TO_CHAR(o.order_date, 'FMDay')
ORDER BY EXTRACT(ISODOW FROM o.order_date);


-- Query 17 — Rank cities by revenue


WITH city_sales AS (
    SELECT c.city,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY c.city
)
SELECT city, revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS city_rank
FROM city_sales
ORDER BY city_rank;


-- Query 18 — Customers with at least two completed orders and spending above ₹5,000


SELECT c.customer_name,
       COUNT(DISTINCT o.order_id) AS order_count,
       SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) >= 2
   AND SUM(oi.quantity * oi.unit_price) > 5000
ORDER BY total_spending DESC;
