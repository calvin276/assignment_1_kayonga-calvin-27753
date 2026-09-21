# Assignment 1 — Sunrise Supermarket SQL Analysis


## Name: KAYONGA CALVIN


## Student ID:** 27753


**DBMS used:** SQLite 3 (chosen because it requires no server install and the whole project — schema, data, and queries — can be run from a single file with the `sqlite3` command-line tool or Python's built-in `sqlite3` module). The schema below still uses Oracle-style type names (`NUMBER`, `VARCHAR2`) as given in the assignment brief; SQLite accepts these directly through its type-affinity system, so the DDL did not need to be rewritten.

## Summary

This project models a small supermarket's sales data — customers, products, orders, and order items — and answers management's questions about *who the customers are, what they buy, and how sales trend over time* using SQL. It includes:

- A normalized 4-table schema (`customers`, `products`, `orders`, `order_items`) with primary/foreign keys.
- Seed data: 6 customers (one with no orders, to properly exercise a `LEFT JOIN`), 8 products across 4 categories, 15 orders, and 27 order items spread across 15 distinct dates (Jan–Mar 2026).
- 3 required `JOIN` queries, 1 `CTE` query, and 4 window-function queries, each explained below with its actual result set.
- A business interpretation of the results and a list of challenges encountered.

## How to run it

**Requirements:** Python 3 (ships with the `sqlite3` module) — or the `sqlite3` CLI if you have it installed.

```bash
# Option A — using the sqlite3 CLI
sqlite3 sunrise_supermarket.db < schema.sql
sqlite3 sunrise_supermarket.db < data.sql
sqlite3 sunrise_supermarket.db < queries.sql

# Option B — using Python (no CLI needed)
python3 -c "
import sqlite3
conn = sqlite3.connect('sunrise_supermarket.db')
conn.executescript(open('schema.sql').read())
conn.executescript(open('data.sql').read())
conn.commit()
"
# then run individual statements from queries.sql via conn.execute(...)
```

Files in this repo:
| File | Purpose |
|---|---|
| `schema.sql` | `CREATE TABLE` statements for all 4 tables |
| `data.sql` | `INSERT` statements populating all 4 tables |
| `queries.sql` | All required JOIN / CTE / window-function queries |
| `sunrise_supermarket.db` | Pre-built SQLite database (schema + data already loaded) so you can query it immediately without re-running the scripts |
| `README.md` | This file |

---

## Business Scenario

Sunrise Supermarket sells products to customers who place orders containing one or more items. Management wants three questions answered:

1. **Who are our customers?** — their names, cities, and order history.
2. **What do they buy?** — which products, in which categories, at what price and quantity.
3. **How are sales trending over time?** — order frequency, spend ranking, and revenue growth.

## Data Model

```
customers (customer_id PK, customer_name, email, city)
products  (product_id PK, product_name, category, price)
orders    (order_id PK, customer_id FK -> customers, order_date)
order_items (order_item_id PK, order_id FK -> orders, product_id FK -> products, quantity)
```

Seed data loaded: **6 customers** (5 with orders, 1 without — David Habimana — to demonstrate outer joins), **8 products** across **4 categories** (Beverages, Bakery, Dairy, Snacks), **15 orders**, and **27 order items** spanning **15 distinct order dates** from 2026-01-05 to 2026-03-15.

---

## JOIN Queries

### 1. Every order with customer name, city, and order date (INNER JOIN)

```sql
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```

**Explanation:** An `INNER JOIN` matches each row in `orders` to its owning row in `customers` via `customer_id`. Since every order must have a valid customer (enforced by the foreign key), no rows are lost.

**Result (15 rows):**

| order_id | customer_name | city | order_date |
|---|---|---|---|
| 1 | Alice Uwase | Kigali | 2026-01-05 |
| 2 | Jean Bosco | Kigali | 2026-01-06 |
| 3 | Alice Uwase | Kigali | 2026-01-12 |
| 4 | Marie Claire | Musanze | 2026-01-15 |
| 5 | Eric Niyonzima | Huye | 2026-01-18 |
| 6 | Jean Bosco | Kigali | 2026-01-25 |
| 7 | Grace Mukamana | Kigali | 2026-02-01 |
| 8 | Alice Uwase | Kigali | 2026-02-03 |
| 9 | Marie Claire | Musanze | 2026-02-10 |
| 10 | Eric Niyonzima | Huye | 2026-02-14 |
| 11 | Jean Bosco | Kigali | 2026-02-20 |
| 12 | Grace Mukamana | Kigali | 2026-02-25 |
| 13 | Alice Uwase | Kigali | 2026-03-02 |
| 14 | Marie Claire | Musanze | 2026-03-08 |
| 15 | Grace Mukamana | Kigali | 2026-03-15 |

**Business interpretation:** This gives management a straightforward order log tied to customer identity and location — useful for checking regional order volume (Kigali dominates here, with 4 of 5 active customers based there).

---

### 2. Every order item with product name, category, price, and quantity

```sql
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;
```

**Explanation:** Joins the line-item table to `products` so each purchased line shows what was actually bought, not just a `product_id`.

**Result (27 rows, showing first order group as sample — full output in `queries.sql` run):**

| order_item_id | order_id | product_name | category | price | quantity |
|---|---|---|---|---|---|
| 1 | 1 | Coca-Cola 500ml | Beverages | 1.20 | 3 |
| 2 | 1 | White Bread | Bakery | 1.80 | 2 |
| 26 | 1 | Fresh Milk 1L | Dairy | 1.10 | 1 |
| 3 | 2 | Fanta Orange 500ml | Beverages | 1.20 | 5 |
| 4 | 2 | Fresh Milk 1L | Dairy | 1.10 | 1 |
| 5 | 3 | Minute Maid Juice 1L | Beverages | 2.50 | 2 |
| 6 | 4 | Chocolate Croissant | Bakery | 1.50 | 4 |
| 7 | 4 | Cheddar Cheese 200g | Dairy | 3.20 | 1 |
| ... | ... | ... | ... | ... | ... |
| 24 | 15 | White Bread | Bakery | 1.80 | 2 |
| 25 | 15 | Chocolate Croissant | Bakery | 1.50 | 1 |

*(all 27 rows are produced when `queries.sql` is run against `sunrise_supermarket.db`)*

**Business interpretation:** Beverages appear most frequently across order lines, suggesting they're a high-frequency repeat purchase — a good candidate for bundling or a loyalty discount.

---

### 3. All customers and their orders, including customers with no orders (LEFT JOIN)

```sql
SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;
```

**Explanation:** A `LEFT JOIN` keeps every row from `customers` even when there is no matching row in `orders`, filling the order columns with `NULL` for unmatched customers. This is the only way to surface customers who have never placed an order.

**Result (16 rows):**

| customer_id | customer_name | city | order_id | order_date |
|---|---|---|---|---|
| 1 | Alice Uwase | Kigali | 1 | 2026-01-05 |
| 1 | Alice Uwase | Kigali | 3 | 2026-01-12 |
| 1 | Alice Uwase | Kigali | 8 | 2026-02-03 |
| 1 | Alice Uwase | Kigali | 13 | 2026-03-02 |
| 2 | Jean Bosco | Kigali | 2 | 2026-01-06 |
| 2 | Jean Bosco | Kigali | 6 | 2026-01-25 |
| 2 | Jean Bosco | Kigali | 11 | 2026-02-20 |
| 3 | Marie Claire | Musanze | 4 | 2026-01-15 |
| 3 | Marie Claire | Musanze | 9 | 2026-02-10 |
| 3 | Marie Claire | Musanze | 14 | 2026-03-08 |
| 4 | Eric Niyonzima | Huye | 5 | 2026-01-18 |
| 4 | Eric Niyonzima | Huye | 10 | 2026-02-14 |
| 5 | Grace Mukamana | Kigali | 7 | 2026-02-01 |
| 5 | Grace Mukamana | Kigali | 12 | 2026-02-25 |
| 5 | Grace Mukamana | Kigali | 15 | 2026-03-15 |
| **6** | **David Habimana** | **Rubavu** | **NULL** | **NULL** |

**Business interpretation:** David Habimana (customer 6) has registered but never ordered — a candidate for a "welcome back" or first-purchase discount campaign. An `INNER JOIN` would have hidden this customer entirely.

---

## CTE Query

### Customers whose total spend is above the average customer spend

```sql
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(total_spent, 2) AS total_spent
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY total_spent DESC;
```

**Explanation:** The CTE `customer_totals` first computes each customer's total spend as `SUM(quantity × price)` across all their orders and items. The outer query then filters that pre-aggregated result against the average of the same set, comparing each customer's total to the group average without repeating the aggregation logic twice.

**All customer totals (for reference), average = 18.72:**

| customer_id | customer_name | total_spent |
|---|---|---|
| 1 | Alice Uwase | 27.10 |
| 3 | Marie Claire | 25.00 |
| 2 | Jean Bosco | 17.90 |
| 5 | Grace Mukamana | 13.40 |
| 4 | Eric Niyonzima | 10.20 |

**Result — customers above average spend (2 rows):**

| customer_id | customer_name | total_spent |
|---|---|---|
| 1 | Alice Uwase | 27.10 |
| 3 | Marie Claire | 25.00 |

**Business interpretation:** Alice Uwase and Marie Claire are the supermarket's top spenders, each well above the $18.72 average. They're strong candidates for a VIP loyalty tier, while Eric Niyonzima (lowest spend, only 2 orders) may need a re-engagement offer.

---

## Window-Function Queries

### 1. Rank customers by total amount spent, highest first

```sql
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(total_spent, 2) AS total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM customer_totals
ORDER BY spend_rank;
```

**Explanation:** `RANK()` assigns a competitive rank based on `total_spent`, ordered descending. Ties (none in this dataset) would receive the same rank, with a gap in the next rank number.

**Result:**

| customer_id | customer_name | total_spent | spend_rank |
|---|---|---|---|
| 1 | Alice Uwase | 27.10 | 1 |
| 3 | Marie Claire | 25.00 | 2 |
| 2 | Jean Bosco | 17.90 | 3 |
| 5 | Grace Mukamana | 13.40 | 4 |
| 4 | Eric Niyonzima | 10.20 | 5 |

**Business interpretation:** A clean leaderboard for a loyalty or rewards program — Alice Uwase is the #1 customer by revenue contribution.

---

### 2. Number each customer's orders in the order placed

```sql
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders
ORDER BY customer_id, order_sequence;
```

**Explanation:** `ROW_NUMBER()` restarts at 1 for each customer (`PARTITION BY customer_id`) and increments in chronological order of `order_date`, giving each customer their own 1st, 2nd, 3rd… order.

**Result (15 rows):**

| customer_id | order_id | order_date | order_sequence |
|---|---|---|---|
| 1 | 1 | 2026-01-05 | 1 |
| 1 | 3 | 2026-01-12 | 2 |
| 1 | 8 | 2026-02-03 | 3 |
| 1 | 13 | 2026-03-02 | 4 |
| 2 | 2 | 2026-01-06 | 1 |
| 2 | 6 | 2026-01-25 | 2 |
| 2 | 11 | 2026-02-20 | 3 |
| 3 | 4 | 2026-01-15 | 1 |
| 3 | 9 | 2026-02-10 | 2 |
| 3 | 14 | 2026-03-08 | 3 |
| 4 | 5 | 2026-01-18 | 1 |
| 4 | 10 | 2026-02-14 | 2 |
| 5 | 7 | 2026-02-01 | 1 |
| 5 | 12 | 2026-02-25 | 2 |
| 5 | 15 | 2026-03-15 | 3 |

**Business interpretation:** Alice Uwase has placed the most orders (4), reinforcing her position as the top customer both by frequency and spend. This sequencing is also the basis for identifying each customer's "1st order" for onboarding-discount analysis.

---

### 3. Running total of revenue over time, ordered by order date

```sql
WITH order_revenue AS (
    SELECT o.order_id, o.order_date, SUM(oi.quantity * p.price) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY o.order_id, o.order_date
)
SELECT order_id, order_date, ROUND(order_revenue, 2) AS order_revenue,
       ROUND(SUM(order_revenue) OVER (ORDER BY order_date, order_id
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total
FROM order_revenue
ORDER BY order_date, order_id;
```

**Explanation:** The CTE first computes each order's revenue. The outer query then uses a window `SUM()` with an explicit frame (`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`) ordered by date, accumulating revenue chronologically.

**Result (15 rows):**

| order_id | order_date | order_revenue | running_total |
|---|---|---|---|
| 1 | 2026-01-05 | 8.30 | 8.30 |
| 2 | 2026-01-06 | 7.10 | 15.40 |
| 3 | 2026-01-12 | 5.00 | 20.40 |
| 4 | 2026-01-15 | 9.20 | 29.60 |
| 5 | 2026-01-18 | 5.20 | 34.80 |
| 6 | 2026-01-25 | 3.30 | 38.10 |
| 7 | 2026-02-01 | 4.90 | 43.00 |
| 8 | 2026-02-03 | 8.20 | 51.20 |
| 9 | 2026-02-10 | 9.80 | 61.00 |
| 10 | 2026-02-14 | 5.00 | 66.00 |
| 11 | 2026-02-20 | 7.50 | 73.50 |
| 12 | 2026-02-25 | 3.40 | 76.90 |
| 13 | 2026-03-02 | 5.60 | 82.50 |
| 14 | 2026-03-08 | 6.00 | 88.50 |
| 15 | 2026-03-15 | 5.10 | 93.60 |

**Business interpretation:** Total revenue across the observed period grew steadily to $93.60 with no sharp drop-offs, indicating consistent (if modest, given the small seed dataset) sales momentum from January through mid-March 2026.

---

### 4. Days between current and previous order, per customer (customers with >1 order)

```sql
WITH customer_order_gaps AS (
    SELECT customer_id, order_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
           COUNT(*) OVER (PARTITION BY customer_id) AS order_count
    FROM orders
)
SELECT customer_id, order_id, order_date, previous_order_date,
       CAST(julianday(order_date) - julianday(previous_order_date) AS INTEGER) AS days_since_previous_order
FROM customer_order_gaps
WHERE order_count > 1
ORDER BY customer_id, order_date;
```

**Explanation:** `LAG()` looks back one row within each customer's partition (ordered by date) to fetch their previous order date. `COUNT(*) OVER (PARTITION BY customer_id)` counts each customer's total orders so the outer `WHERE` can exclude anyone with only a single order (for whom "days since previous order" is undefined). `julianday()` converts dates to a numeric day count so subtraction gives a day gap. All 5 active customers happen to have more than one order, so each appears with their first order's gap left as `NULL`.

**Result (15 rows):**

| customer_id | order_id | order_date | previous_order_date | days_since_previous_order |
|---|---|---|---|---|
| 1 | 1 | 2026-01-05 | NULL | NULL |
| 1 | 3 | 2026-01-12 | 2026-01-05 | 7 |
| 1 | 8 | 2026-02-03 | 2026-01-12 | 22 |
| 1 | 13 | 2026-03-02 | 2026-02-03 | 27 |
| 2 | 2 | 2026-01-06 | NULL | NULL |
| 2 | 6 | 2026-01-25 | 2026-01-06 | 19 |
| 2 | 11 | 2026-02-20 | 2026-01-25 | 26 |
| 3 | 4 | 2026-01-15 | NULL | NULL |
| 3 | 9 | 2026-02-10 | 2026-01-15 | 26 |
| 3 | 14 | 2026-03-08 | 2026-02-10 | 26 |
| 4 | 5 | 2026-01-18 | NULL | NULL |
| 4 | 10 | 2026-02-14 | 2026-01-18 | 27 |
| 5 | 7 | 2026-02-01 | NULL | NULL |
| 5 | 12 | 2026-02-25 | 2026-02-01 | 24 |
| 5 | 15 | 2026-03-15 | 2026-02-25 | 18 |

**Business interpretation:** Most customers re-order roughly every 3–4 weeks (18–27 day gaps), suggesting a monthly shopping cycle. This is useful for timing re-engagement emails: if a customer passes ~30 days without a new order relative to their historical gap, that's a signal to send a reminder.

---

## Challenges & Resolutions

1. **Oracle-specific types (`NUMBER`, `VARCHAR2`) in a non-Oracle DBMS.** SQLite doesn't enforce strict typing but does accept arbitrary declared types through type affinity, so the original `CREATE TABLE` statements from the brief could be used unmodified rather than rewritten into a different dialect.
2. **Computing "total spend" required joining across three tables** (`customers` → `orders` → `order_items` → `products`) before aggregating. Resolved by building a single reusable CTE (`customer_totals`) that computes the aggregate once, then reusing that same pattern for both the CTE query and the ranking window-function query, avoiding duplicated aggregation logic.
3. **`LAG()` needed comparable, subtractable dates.** SQLite stores `DATE` values as plain text, so subtracting two date strings directly isn't meaningful. Resolved using SQLite's `julianday()` function to convert both dates to numeric Julian day values before subtracting, then casting to an integer day count.
4. **Excluding customers with only one order from the "days between orders" query** required knowing each customer's total order count *before* filtering. Resolved with a second window function, `COUNT(*) OVER (PARTITION BY customer_id)`, computed alongside `LAG()` in the same CTE, so the outer query could filter on `order_count > 1` without a second pass over the data.
5. **Demonstrating a true `LEFT JOIN` case** required at least one customer with zero orders. Deliberately added customer 6 (David Habimana) with no rows in `orders`, confirmed the `LEFT JOIN` query returns `NULL` order fields for that customer instead of silently dropping the row.
