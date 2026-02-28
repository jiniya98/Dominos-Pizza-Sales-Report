create database Dominos_db;
use Dominos_db;

CREATE TABLE customers (
    custid INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20)
);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    order_time TIME,
    custid INT,
    status VARCHAR(20),
    FOREIGN KEY (custid) REFERENCES customers(custid)
);


CREATE TABLE pizza_types (
    pizza_type VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients TEXT
);


CREATE TABLE pizza (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type VARCHAR(50),
    size VARCHAR(10),
    price DECIMAL(6,2),
    FOREIGN KEY (pizza_type) REFERENCES pizza_types(pizza_type)
);


CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (pizza_id) REFERENCES pizza(pizza_id)
);
SELECT COUNT(DISTINCT order_id) AS total_unique_orders
FROM orders;


/*2 How many orders were placed each month and year*/
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

/*3. On which days of the week are orders most frequently placed*/

SELECT 
    DAYNAME(order_date) AS weekday,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY DAYNAME(order_date)
ORDER BY FIELD(weekday, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

/* 4. On average, how many orders does each customer place?*/

SELECT 
    ROUND(COUNT(order_id) / COUNT(DISTINCT custid), 2) AS avg_orders_per_customer
FROM orders;

/* 5 .Which customers placed more than one order, and how many orders did they place*/

SELECT 
    c.custid,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o 
    ON c.custid = o.custid
GROUP BY c.custid, customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

/* How does the total number of orders accumulate over time?*/

SELECT 
    order_date,
    COUNT(order_id) AS daily_orders,
    SUM(COUNT(order_id)) OVER (ORDER BY order_date) AS cumulative_orders
FROM orders
GROUP BY order_date
ORDER BY order_date;

/*What is the total revenue generated from all pizza sales in the dataset?*/
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizza p 
    ON od.pizza_id = p.pizza_id;
    
/* Which pizza on the menu has the highest price?”*/
SELECT pizza_id,pizza_type,size,price
FROM pizza
ORDER BY price desc
LIMIT 1;

/* Which pizza size is ordered most frequently across all orders?*/
SELECT 
    p.size,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p 
    ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;


/* Which 5 pizza types were sold the most, based on total quantity order*/
SELECT 
    p.pizza_type,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p 
    ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type
ORDER BY total_quantity DESC
LIMIT 5;


/* “How many pizzas were sold in each category?”*/
SELECT 
    p.pizza_type,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p 
    ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type
ORDER BY total_quantity DESC;


/* “At which hours of the day are orders most frequently placed?”*/
SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;




/* How many pizzas were sold in each category, and what percentage share does each category hold?”*/

SELECT 
    p.pizza_type,
    SUM(od.quantity) AS total_quantity,
    ROUND(SUM(od.quantity) * 100.0 / (SELECT SUM(quantity) FROM order_details), 2) AS percentage_share
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type
ORDER BY total_quantity DESC;


/* What is the average number of pizzas ordered per day?”*/

SELECT 
    ROUND(SUM(od.quantity) / COUNT(DISTINCT o.order_date), 2) AS avg_pizzas_per_day
FROM orders o
JOIN order_details od ON o.order_id = od.order_id;


/* Which 3 pizzas generated the highest revenue?”*/
SELECT 
    p.pizza_type,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type
ORDER BY total_revenue DESC
LIMIT 3;


/* What percentage of total revenue does each pizza contribute?”*/
SELECT 
    p.pizza_type,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue,
    ROUND(SUM(od.quantity * p.price) * 100.0 / 
          (SELECT SUM(od2.quantity * p2.price) 
           FROM order_details od2 JOIN pizza p2 ON od2.pizza_id = p2.pizza_id), 2) AS percentage_share
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type
ORDER BY revenue DESC;


/* “How does revenue accumulate month by month?”*/
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(od.quantity * p.price) AS monthly_revenue,
    SUM(SUM(od.quantity * p.price)) OVER (ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY month
ORDER BY month;


/* Which 3 pizzas generate the most revenue in each category?”*/
SELECT 
    p.pizza_type,
    p.size,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type, p.size
ORDER BY p.pizza_type, revenue DESC
LIMIT 3;


/* Which customers spent the most overall?”*/
SELECT 
    c.custid,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.custid = o.custid
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY c.custid, customer_name
ORDER BY total_spent DESC
LIMIT 10;


/* Which weekdays have the most orders?”*/
SELECT 
    DAYNAME(order_date) AS weekday,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY weekday
ORDER BY order_count DESC;


/* On average, how many pizzas are in each order?”*/
SELECT 
    ROUND(SUM(od.quantity) / COUNT(DISTINCT o.order_id), 2) AS avg_order_size
FROM orders o
JOIN order_details od ON o.order_id = od.order_id;


/* What are the monthly and holiday sales patterns?”*/
SELECT 
    MONTH(order_date) AS month,
    SUM(od.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY month
ORDER BY month;


/* “How much revenue does each pizza size contribute?”*/
SELECT 
    p.size,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue DESC;


/* “Classify customers as High Value or Regular based on spend.”*/
SELECT 
    c.custid,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(od.quantity * p.price) AS total_spent,
    CASE 
        WHEN SUM(od.quantity * p.price) > 500 THEN 'High Value'
        ELSE 'Regular'
    END AS customer_segment
FROM customers c
JOIN orders o ON c.custid = o.custid
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY c.custid, customer_name
ORDER BY total_spent DESC;


/* What percentage of customers placed more than one order?”*/
SELECT 
    ROUND(COUNT(DISTINCT CASE WHEN order_count > 1 THEN custid END) * 100.0 / COUNT(DISTINCT custid), 2) AS repeat_customer_rate
FROM (
    SELECT custid, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY custid
) t;
