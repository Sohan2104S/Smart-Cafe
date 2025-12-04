/*==========================================================
   SMART CAFÉ RECOMMENDATION & ORDER ANALYSIS SYSTEM
   QUERIES FILE - queries.sql
==========================================================*/


/*----------------------------------------------------------
  1. BASIC QUERIES
----------------------------------------------------------*/

-- 1.1 Get all customers
SELECT * FROM customers;

-- 1.2 Get all menu items
SELECT * FROM menu_items;

-- 1.3 Get all orders with customer names
SELECT o.order_id, c.name AS customer_name, o.order_date, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;


/*----------------------------------------------------------
  2. AGGREGATION & ANALYTICS
----------------------------------------------------------*/

-- 2.1 Count total number of orders
SELECT COUNT(*) AS total_orders FROM orders;

-- 2.2 Total revenue generated
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- 2.3 Total items sold
SELECT SUM(quantity) AS total_items_sold FROM order_items;


/*----------------------------------------------------------
  3. POPULARITY ANALYSIS
----------------------------------------------------------*/

-- 3.1 Most ordered item
SELECT m.item_name, SUM(oi.quantity) AS total_sold
FROM menu_items m
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.item_name
ORDER BY total_sold DESC
LIMIT 1;

-- 3.2 Least ordered item
SELECT m.item_name, SUM(oi.quantity) AS total_sold
FROM menu_items m
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.item_name
ORDER BY total_sold ASC
LIMIT 1;

-- 3.3 Item-wise sales list
SELECT m.item_name, SUM(oi.quantity) AS total_sold
FROM menu_items m
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.item_name
ORDER BY total_sold DESC;


/*----------------------------------------------------------
  4. RATINGS & REVIEWS ANALYSIS
----------------------------------------------------------*/

-- 4.1 Highest-rated item
SELECT m.item_name, AVG(r.rating) AS avg_rating
FROM menu_items m
JOIN ratings r ON m.item_id = r.item_id
GROUP BY m.item_name
ORDER BY avg_rating DESC
LIMIT 1;

-- 4.2 Lowest-rated item
SELECT m.item_name, AVG(r.rating) AS avg_rating
FROM menu_items m
JOIN ratings r ON m.item_id = r.item_id
GROUP BY m.item_name
ORDER BY avg_rating ASC
LIMIT 1;

-- 4.3 All items with average ratings
SELECT m.item_name, ROUND(AVG(r.rating), 2) AS average_rating
FROM menu_items m
LEFT JOIN ratings r ON m.item_id = r.item_id
GROUP BY m.item_name
ORDER BY average_rating DESC;


/*----------------------------------------------------------
  5. CUSTOMER ANALYSIS
----------------------------------------------------------*/

-- 5.1 Loyal customers (more than 2 orders)
SELECT c.name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name
HAVING total_orders > 2;

-- 5.2 Customers who placed only one order
SELECT c.name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name
HAVING total_orders = 1;

-- 5.3 Customers who never ordered
SELECT name
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders);


/*----------------------------------------------------------
  6. SALES TREND ANALYSIS
----------------------------------------------------------*/

-- 6.1 Daily sales
SELECT order_date, SUM(total_amount) AS daily_sales
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- 6.2 Monthly sales
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS total_sales
FROM orders
GROUP BY month
ORDER BY month;

-- 6.3 Top-selling categories
SELECT m.category, SUM(oi.quantity) AS items_sold
FROM menu_items m
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.category
ORDER BY items_sold DESC;


/*----------------------------------------------------------
  7. SMART RECOMMENDATION ENGINE
----------------------------------------------------------*/

-- 7.1 Recommended items (rating >= 4 AND high sales)
SELECT m.item_name
FROM menu_items m
JOIN ratings r ON m.item_id = r.item_id
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.item_name
HAVING AVG(r.rating) >= 4 AND SUM(oi.quantity) > 20;

-- 7.2 “Similar Items” recommendation (same category)
SELECT item_name, category
FROM menu_items
WHERE category = (
    SELECT category
    FROM menu_items
    WHERE item_id = 101
);


/*----------------------------------------------------------
  8. WINDOW FUNCTIONS (ADVANCED SQL)
----------------------------------------------------------*/

-- 8.1 Rank items by sales
SELECT 
    m.item_name,
    SUM(oi.quantity) AS total_sold,
    RANK() OVER(ORDER BY SUM(oi.quantity) DESC) AS sales_rank
FROM menu_items m
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.item_name;

-- 8.2 Rank customers by total spending
SELECT 
    c.name,
    SUM(o.total_amount) AS total_spent,
    DENSE_RANK() OVER(ORDER BY SUM(o.total_amount) DESC) AS spending_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- 8.3 Average rating per item using window functions
SELECT 
    m.item_name,
    r.rating,
    AVG(r.rating) OVER (PARTITION BY r.item_id) AS avg_item_rating
FROM ratings r
JOIN menu_items m ON r.item_id = m.item_id;


/*----------------------------------------------------------
  9. SUBQUERY BASED QUERIES
----------------------------------------------------------*/

-- 9.1 Items ordered more than system average
SELECT item_name
FROM menu_items
WHERE item_id IN (
    SELECT item_id
    FROM order_items
    GROUP BY item_id
    HAVING SUM(quantity) > (
        SELECT AVG(total_qty)
        FROM (
            SELECT SUM(quantity) AS total_qty
            FROM order_items
            GROUP BY item_id
        ) AS avg_sales
    )
);

-- 9.2 Orders above average bill value
SELECT *
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);


/*----------------------------------------------------------
  10. JOINS (DEMONSTRATION)
----------------------------------------------------------*/

-- 10.1 Orders with item details
SELECT o.order_id, m.item_name, oi.quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN menu_items m ON oi.item_id = m.item_id;

-- 10.2 Customers with their reviews
SELECT c.name, m.item_name, r.rating, r.review
FROM customers c
JOIN ratings r ON c.customer_id = r.customer_id
JOIN menu_items m ON r.item_id = m.item_id;


/*----------------------------------------------------------
  11. VIEWS (OPTIONAL BUT IMPRESSIVE)
----------------------------------------------------------*/

-- 11.1 View: best selling items
CREATE VIEW best_selling_items AS
SELECT m.item_name, SUM(oi.quantity) AS total_sold
FROM menu_items m
JOIN order_items oi ON m.item_id = oi.item_id
GROUP BY m.item_name
ORDER BY total_sold DESC;

-- 11.2 View: customer summary
CREATE VIEW customer_summary AS
SELECT c.name, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name;


/*----------------------------------------------------------
  END OF FILE
----------------------------------------------------------*/
