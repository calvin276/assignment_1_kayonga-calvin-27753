-- ============================================================
-- Sunrise Supermarket — Analysis Queries
-- ============================================================

-- ------------------------------------------------------------
-- JOIN 1: Every order with customer name, city, and order date
-- ------------------------------------------------------------
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;


-- ------------------------------------------------------------
-- JOIN 2: Every order item with product name, category, price, qty
-- ------------------------------------------------------------
SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;


-- ------------------------------------------------------------
-- JOIN 3: All customers and their orders, including those with none
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;


-- ------------------------------------------------------------
-- CTE: Customers whose total spend is above the average spend
-- ------------------------------------------------------------
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o        ON o.customer_id = c.customer_id
    JOIN order_items oi  ON oi.order_id = o.order_id
    JOIN products p      ON p.product_id = oi.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spent, 2) AS total_spent
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY total_spent DESC;


-- ------------------------------------------------------------
-- WINDOW 1: Rank customers by total amount spent, highest first
-- ------------------------------------------------------------
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o        ON o.customer_id = c.customer_id
    JOIN order_items oi  ON oi.order_id = o.order_id
    JOIN products p      ON p.product_id = oi.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spent, 2) AS total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM customer_totals
ORDER BY spend_rank;


-- ------------------------------------------------------------
-- WINDOW 2: Number each customer's orders in the order placed
-- ------------------------------------------------------------
SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders
ORDER BY customer_id, order_sequence;


-- ------------------------------------------------------------
-- WINDOW 3: Running total of revenue over time, ordered by date
-- ------------------------------------------------------------
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.order_date,
        SUM(oi.quantity * p.price) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    GROUP BY o.order_id, o.order_date
)
SELECT
    order_id,
    order_date,
    ROUND(order_revenue, 2) AS order_revenue,
    ROUND(SUM(order_revenue) OVER (ORDER BY order_date, order_id
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total
FROM order_revenue
ORDER BY order_date, order_id;


-- ------------------------------------------------------------
-- WINDOW 4: Days between current and previous order, per customer
--           (only customers with more than one order)
-- ------------------------------------------------------------
WITH customer_order_gaps AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
        COUNT(*) OVER (PARTITION BY customer_id) AS order_count
    FROM orders
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    CAST(julianday(order_date) - julianday(previous_order_date) AS INTEGER) AS days_since_previous_order
FROM customer_order_gaps
WHERE order_count > 1
ORDER BY customer_id, order_date;
