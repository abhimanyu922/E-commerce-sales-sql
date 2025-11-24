-- Schema for E-Commerce Sales Analytics (Mini)
CREATE DATABASE IF NOT EXISTS ecommerce_sales_analytics;
USE ecommerce_sales_analytics;

CREATE TABLE users (
  user_id INT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  signup_date DATE
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(255),
  category VARCHAR(100),
  price DECIMAL(10,2),
  cost DECIMAL(10,2)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  user_id INT,
  order_date DATETIME,
  status VARCHAR(50),
  total_amount DECIMAL(12,2),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  order_id INT,
  payment_method VARCHAR(50),
  amount DECIMAL(12,2),
  payment_time DATETIME,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shipments (
  shipment_id INT PRIMARY KEY,
  order_id INT,
  city VARCHAR(100),
  shipped_at DATETIME,
  delivered_at DATETIME,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE merchants (
    merchant_id INT PRIMARY KEY,
    merchant_name VARCHAR(100),
    city VARCHAR(100)
);

-- -----------------------------------
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM shipments;
SELECT COUNT(*) FROM merchants;

SELECT * FROM users LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM payments LIMIT 10;
SELECT * FROM shipments LIMIT 10;
SELECT * FROM merchants LIMIT 10;



  -- E-COMMERCE KPI QUERIES 
   

--------------------------------------------------------------------------------
-- 1) What is the total daily sales revenue across the platform?
-- Sum of order totals grouped by order date (delivered + processing considered).
--------------------------------------------------------------------------------
SELECT
  DATE(orders.order_date) AS order_date,
  ROUND(SUM(orders.total_amount),2) AS total_daily_revenue
FROM orders
GROUP BY DATE(orders.order_date)
ORDER BY DATE(orders.order_date);

--------------------------------------------------------------------------------
-- 2) How many orders are placed each day, week, and month?
--------------------------------------------------------------------------------
-- Orders per day
SELECT
  DATE(orders.order_date) AS order_date,
  COUNT(orders.order_id) AS orders_per_day
FROM orders
GROUP BY DATE(orders.order_date)
ORDER BY DATE(orders.order_date);

-- Orders per week (ISO week)
SELECT
  DATE_FORMAT(orders.order_date, '%Y-%u') AS order_week,
  COUNT(orders.order_id) AS orders_per_week
FROM orders
GROUP BY DATE_FORMAT(orders.order_date, '%Y-%u')
ORDER BY DATE_FORMAT(orders.order_date, '%Y-%u');

-- Orders per month
SELECT
  DATE_FORMAT(orders.order_date, '%Y-%m') AS order_month,
  COUNT(orders.order_id) AS orders_per_month
FROM orders
GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
ORDER BY DATE_FORMAT(orders.order_date, '%Y-%m');

--------------------------------------------------------------------------------
-- 3) Which products generate the highest revenue?
--------------------------------------------------------------------------------
SELECT
  products.product_id,
  products.product_name,
  ROUND(SUM(order_items.quantity * order_items.unit_price),2) AS product_revenue
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
INNER JOIN orders
  ON order_items.order_id = orders.order_id
GROUP BY
  products.product_id,
  products.product_name
ORDER BY product_revenue DESC
LIMIT 20;

--------------------------------------------------------------------------------
-- 4) Which product categories contribute the most to total sales?
--------------------------------------------------------------------------------
SELECT
  products.category,
  ROUND(SUM(order_items.quantity * order_items.unit_price),2) AS category_revenue
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
INNER JOIN orders
  ON order_items.order_id = orders.order_id
GROUP BY products.category
ORDER BY category_revenue DESC;

--------------------------------------------------------------------------------
-- 5) What is the average order value (AOV) per customer?
--------------------------------------------------------------------------------
SELECT
  users.user_id,
  users.first_name,
  users.last_name,
  ROUND(AVG(orders.total_amount),2) AS average_order_value
FROM users
INNER JOIN orders
  ON users.user_id = orders.user_id
GROUP BY
  users.user_id,
  users.first_name,
  users.last_name
ORDER BY average_order_value DESC
LIMIT 50;

--------------------------------------------------------------------------------
-- 6) Who are the top 10 highest-spending customers?
--------------------------------------------------------------------------------
SELECT
  users.user_id,
  users.first_name,
  users.last_name,
  ROUND(SUM(orders.total_amount),2) AS total_spent
FROM users
INNER JOIN orders
  ON users.user_id = orders.user_id
GROUP BY
  users.user_id,
  users.first_name,
  users.last_name
ORDER BY total_spent DESC
LIMIT 10;

--------------------------------------------------------------------------------
-- 7) What percentage of orders are delivered vs cancelled vs returned?
--------------------------------------------------------------------------------
SELECT
  orders.status,
  COUNT(orders.order_id) AS count_by_status,
  ROUND(COUNT(orders.order_id) / NULLIF((SELECT COUNT(*) FROM orders),0) * 100,2) AS percent_of_total
FROM orders
GROUP BY orders.status;

--------------------------------------------------------------------------------
-- 8) Which payment method is most used?
--------------------------------------------------------------------------------
SELECT
  payments.payment_method,
  COUNT(payments.payment_id) AS usage_count,
  ROUND(COUNT(payments.payment_id) / NULLIF((SELECT COUNT(*) FROM payments),0) * 100,2) AS usage_percent
FROM payments
GROUP BY payments.payment_method
ORDER BY usage_count DESC;

--------------------------------------------------------------------------------
-- 9) How many unique customers purchased in the last 30 days?
--------------------------------------------------------------------------------
SELECT
  COUNT(DISTINCT orders.user_id) AS unique_buyers_last_30_days
FROM orders
WHERE orders.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

--------------------------------------------------------------------------------
-- 10) What is the repeat purchase rate of customers?
-- Repeat purchase rate = percent of customers with >1 orders
--------------------------------------------------------------------------------
SELECT
  ROUND(SUM(CASE WHEN customer_order_count > 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0) * 100,2) AS repeat_purchase_rate_percent
FROM (
  SELECT
    orders.user_id,
    COUNT(orders.order_id) AS customer_order_count
  FROM orders
  GROUP BY orders.user_id
) AS derived_customer_orders;

--------------------------------------------------------------------------------
-- 11) What is the total number of items sold per product?
--------------------------------------------------------------------------------
SELECT
  products.product_id,
  products.product_name,
  SUM(order_items.quantity) AS total_quantity_sold
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
GROUP BY
  products.product_id,
  products.product_name
ORDER BY total_quantity_sold DESC
LIMIT 50;

--------------------------------------------------------------------------------
-- 12) Which products have the highest profit margin?
-- Profit per product = SUM((unit_price - cost) * quantity)
--------------------------------------------------------------------------------
SELECT
  products.product_id,
  products.product_name,
  ROUND(SUM((order_items.unit_price - products.cost) * order_items.quantity),2) AS total_profit
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
GROUP BY
  products.product_id,
  products.product_name
ORDER BY total_profit DESC
LIMIT 20;

--------------------------------------------------------------------------------
-- 13) What is the month-on-month revenue growth rate?
-- Returns month, revenue, and percent change vs previous month
--------------------------------------------------------------------------------
SELECT
  month_revenue.month AS month,
  month_revenue.monthly_revenue,
  ROUND((month_revenue.monthly_revenue - LAG(month_revenue.monthly_revenue) OVER (ORDER BY month_revenue.month)) / NULLIF(LAG(month_revenue.monthly_revenue) OVER (ORDER BY month_revenue.month),0) * 100,2) AS percent_change_vs_prev_month
FROM (
  SELECT
    DATE_FORMAT(orders.order_date, '%Y-%m') AS month,
    ROUND(SUM(orders.total_amount),2) AS monthly_revenue
  FROM orders
  GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
) AS month_revenue
ORDER BY month_revenue.month;

--------------------------------------------------------------------------------
-- 14) What percentage of orders contain more than 3 items?
--------------------------------------------------------------------------------
SELECT
  ROUND(SUM(CASE WHEN item_counts.items_in_order > 3 THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0) * 100,2) AS percent_orders_more_than_3_items
FROM (
  SELECT
    order_items.order_id,
    SUM(order_items.quantity) AS items_in_order
  FROM order_items
  GROUP BY order_items.order_id
) AS item_counts
INNER JOIN orders
  ON item_counts.order_id = orders.order_id;

--------------------------------------------------------------------------------
-- 15) Which cities have the highest order volume?
--------------------------------------------------------------------------------
SELECT
  shipments.city,
  COUNT(shipments.shipment_id) AS orders_shipped
FROM shipments
INNER JOIN orders
  ON shipments.order_id = orders.order_id
GROUP BY shipments.city
ORDER BY orders_shipped DESC;

--------------------------------------------------------------------------------
-- 16) Which cities have the fastest and slowest delivery times?
-- Delivery time = TIMESTAMPDIFF in hours between shipped_at and delivered_at (only delivered orders)
--------------------------------------------------------------------------------
SELECT
  AVG(TIMESTAMPDIFF(HOUR, shipments.shipped_at, shipments.delivered_at)) AS avg_delivery_time_hours,
  shipments.city
FROM shipments
WHERE shipments.delivered_at IS NOT NULL AND shipments.delivered_at <> ''
GROUP BY shipments.city
ORDER BY avg_delivery_time_hours ASC;

--------------------------------------------------------------------------------
-- 17) Which users have the highest cart abandonment rate?
-- NOTE: requires cart table; using heuristic: payments amount = 0 and order status not 'delivered' implies abandoned.
--------------------------------------------------------------------------------
SELECT
  users.user_id,
  users.first_name,
  users.last_name,
  SUM(CASE WHEN orders.total_amount = 0 OR orders.status != 'delivered' THEN 1 ELSE 0 END) AS potential_abandoned_orders,
  COUNT(orders.order_id) AS total_orders
FROM users
LEFT JOIN orders
  ON users.user_id = orders.user_id
GROUP BY
  users.user_id,
  users.first_name,
  users.last_name
ORDER BY potential_abandoned_orders DESC
LIMIT 50;

--------------------------------------------------------------------------------
-- 18) What are the top-selling products during peak hours?
-- Peak hours defined here as 18:00-21:00
--------------------------------------------------------------------------------
SELECT
  products.product_id,
  products.product_name,
  SUM(order_items.quantity) AS qty_sold_peak_hours
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
INNER JOIN orders
  ON order_items.order_id = orders.order_id
WHERE HOUR(orders.order_date) BETWEEN 18 AND 21
GROUP BY
  products.product_id,
  products.product_name
ORDER BY qty_sold_peak_hours DESC
LIMIT 20;

--------------------------------------------------------------------------------
-- 19) What is the distribution of order statuses by product category?
--------------------------------------------------------------------------------
SELECT
  products.category,
  orders.status,
  COUNT(orders.order_id) AS orders_count
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
INNER JOIN orders
  ON order_items.order_id = orders.order_id
GROUP BY
  products.category,
  orders.status
ORDER BY products.category, orders.status;

--------------------------------------------------------------------------------
-- 20) What is the average processing time from order to shipment?
-- Processing time = time between orders.order_date and shipments.shipped_at
--------------------------------------------------------------------------------
SELECT
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, orders.order_date, shipments.shipped_at)),2) AS avg_processing_minutes
FROM orders
INNER JOIN shipments
  ON orders.order_id = shipments.order_id
WHERE shipments.shipped_at IS NOT NULL AND shipments.shipped_at <> '';

-- E-COMMERCE FRAUD DETECTION QUERIES
  

--------------------------------------------------------------------------------
-- F1) Are there users placing an unusually high number of orders within a short time window?
-- Example: more than 5 orders within a single day
--------------------------------------------------------------------------------
SELECT
  orders.user_id,
  COUNT(orders.order_id) AS orders_in_one_day,
  DATE(orders.order_date) AS order_day
FROM orders
GROUP BY
  orders.user_id,
  DATE(orders.order_date)
HAVING orders_in_one_day > 5
ORDER BY orders_in_one_day DESC;

--------------------------------------------------------------------------------
-- F2) Are multiple users using the same delivery address but different accounts?
-- (Assumes shipments table has address fields; using city as proxy here.)
--------------------------------------------------------------------------------
SELECT
  shipments.city,
  COUNT(DISTINCT orders.user_id) AS different_users_at_same_city,
  GROUP_CONCAT(DISTINCT orders.user_id) AS users_list
FROM shipments
INNER JOIN orders
  ON shipments.order_id = orders.order_id
GROUP BY shipments.city
HAVING different_users_at_same_city > 3
ORDER BY different_users_at_same_city DESC;

--------------------------------------------------------------------------------
-- F3) Are there multiple refunds generated by the same user in a short period?
-- (refunds considered as orders.status = 'returned' OR payments negative)
--------------------------------------------------------------------------------
SELECT
  orders.user_id,
  COUNT(orders.order_id) AS refund_count,
  MIN(orders.order_date) AS first_refund,
  MAX(orders.order_date) AS last_refund
FROM orders
WHERE orders.status = 'returned'
GROUP BY orders.user_id
HAVING refund_count >= 3
ORDER BY refund_count DESC;

--------------------------------------------------------------------------------
-- F4) Are high-priced items being ordered repeatedly by the same user and returned frequently?
--------------------------------------------------------------------------------
SELECT
  users.user_id,
  users.first_name,
  users.last_name,
  products.product_id,
  products.product_name,
  COUNT(orders.order_id) AS times_ordered,
  SUM(CASE WHEN orders.status = 'returned' THEN 1 ELSE 0 END) AS times_returned
FROM users
INNER JOIN orders
  ON users.user_id = orders.user_id
INNER JOIN order_items
  ON orders.order_id = order_items.order_id
INNER JOIN products
  ON order_items.product_id = products.product_id
WHERE products.price > 2000
GROUP BY
  users.user_id,
  users.first_name,
  users.last_name,
  products.product_id,
  products.product_name
HAVING times_ordered >= 2 AND times_returned >= 1
ORDER BY times_returned DESC;

--------------------------------------------------------------------------------
-- F5) Are there many failed payments for the same user?
--------------------------------------------------------------------------------
SELECT
  payments.order_id,
  orders.user_id,
  payments.payment_method,
  payments.amount,
  payments.payment_time
FROM payments
INNER JOIN orders
  ON payments.order_id = orders.order_id
WHERE payments.amount = 0
ORDER BY payments.payment_time DESC
LIMIT 100;

--------------------------------------------------------------------------------
-- F6) Are multiple user accounts sharing the same IP address (possible fraud ring)?
-- (If IP is recorded in payments or shipments; using payments.payment_time as proxy not IP — if IP not available skip)
-- Here we check if many orders originate from same email domains or same shipping city and same payment method — proxy check
--------------------------------------------------------------------------------
SELECT
  payments.payment_method,
  shipments.city,
  COUNT(DISTINCT orders.user_id) AS unique_users
FROM payments
INNER JOIN orders
  ON payments.order_id = orders.order_id
INNER JOIN shipments
  ON orders.order_id = shipments.order_id
GROUP BY
  payments.payment_method,
  shipments.city
HAVING unique_users > 5
ORDER BY unique_users DESC;

--------------------------------------------------------------------------------
-- F7) Are there users with multiple refunds and many different delivery addresses?
--------------------------------------------------------------------------------
SELECT
  orders.user_id,
  COUNT(DISTINCT shipments.city) AS distinct_delivery_cities,
  SUM(CASE WHEN orders.status = 'returned' THEN 1 ELSE 0 END) AS total_returns
FROM orders
LEFT JOIN shipments
  ON orders.order_id = shipments.order_id
GROUP BY orders.user_id
HAVING total_returns >= 2 AND distinct_delivery_cities > 2
ORDER BY total_returns DESC;

--------------------------------------------------------------------------------
-- F8) Is there a high return-to-sale ratio for a product (possible quality/fraud issue)?
--------------------------------------------------------------------------------
SELECT
  products.product_id,
  products.product_name,
  SUM(order_items.quantity) AS total_sold,
  SUM(CASE WHEN orders.status = 'returned' THEN order_items.quantity ELSE 0 END) AS total_returned,
  ROUND(SUM(CASE WHEN orders.status = 'returned' THEN order_items.quantity ELSE 0 END) / NULLIF(SUM(order_items.quantity),0) * 100,2) AS return_percent
FROM products
INNER JOIN order_items
  ON products.product_id = order_items.product_id
INNER JOIN orders
  ON order_items.order_id = orders.order_id
GROUP BY
  products.product_id,
  products.product_name
HAVING return_percent > 20
ORDER BY return_percent DESC;

--------------------------------------------------------------------------------
-- F9) Detect shipping address reuse across multiple payment methods (suspicious)
--------------------------------------------------------------------------------
SELECT
  shipments.city,
  COUNT(DISTINCT payments.payment_method) AS distinct_payment_methods,
  COUNT(DISTINCT orders.user_id) AS distinct_users
FROM shipments
INNER JOIN orders
  ON shipments.order_id = orders.order_id
INNER JOIN payments
  ON orders.order_id = payments.order_id
GROUP BY shipments.city
HAVING distinct_payment_methods > 3 AND distinct_users > 3
ORDER BY distinct_payment_methods DESC;

--------------------------------------------------------------------------------
-- F10) Suspicious orders placed late at night with high value
--------------------------------------------------------------------------------
SELECT
  orders.order_id,
  orders.user_id,
  orders.order_date,
  orders.total_amount
FROM orders
WHERE HOUR(orders.order_date) BETWEEN 0 AND 4
  AND orders.total_amount > 2000
ORDER BY orders.total_amount DESC;

