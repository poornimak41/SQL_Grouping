/*********************** GETTING THE DATA ***********************************/
CREATE TABLE customers(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(20) NOT NULL,
	region VARCHAR(15) NOT NULL);

CREATE TABLE orders(
	order_id INT PRIMARY KEY,
	customer_id INT,
	order_date DATE NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id));

CREATE TABLE products(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(30) NOT NULL,
	category VARCHAR(30) NOT NULL,
	unit_price DECIMAL);
	
CREATE TABLE order_details(
	order_id INT,
	product_id INT,
	quantity INT NOT NULL,
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	PRIMARY KEY (order_id,product_id));
--USE IMPORT/EXPORT OPTION	
SELECT * FROM public.customers;
SELECT * FROM public.products;
SELECT * FROM public.orders;
SELECT * FROM public.order_details;

/*********************************************************************/
	/***** AGGREGATE FUNCTIONS ********/
/*How many customers are there in the dataset? */
SELECT COUNT(customer_id) FROM public.customers;
/*What is the minimum unit price in the ELectronics category? */
SELECT MIN(unit_price) FROM public.products 
WHERE category = 'Electronics';

/* What is the overall grand total of sales? */
--sales = unit_price*quantity 
SELECT SUM(quantity*unit_price) AS grand_total_sales FROM public.order_details od 
JOIN public.products p ON p.product_id = od.product_id;

/*  How many customers are there in each region */
SELECT region,min(customer_name), COUNT(customer_id) AS num_customers FROM public.customers 
GROUP BY region;

/*  How many products are there in each category */
SELECT category,COUNT(*) AS num_products FROM public.products 
GROUP BY category;

/*  How many orders were placed on each day? */
SELECT order_date, COUNT(order_id) AS total_orders_by_day FROM public.orders 
GROUP BY order_date;

/* What is the region wise sales? */
SELECT region, SUM(unit_price * quantity) AS sales FROM public.customers c
left JOIN public.orders o ON o.customer_id = c.customer_id
left JOIN public.order_details od ON od.order_id = o.order_id
left JOIN public.products p ON p.product_id = od.product_id
GROUP  BY region ORDER BY region;

SELECT  SUM(unit_price * quantity) AS north_sales FROM public.customers c
JOIN public.orders o ON o.customer_id = c.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id
WHERE region = 'North';

SELECT region, SUM(unit_price * quantity) AS sales FROM public.customers c
JOIN public.orders o ON o.customer_id = c.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id
GROUP BY region 
HAVING region IN ('East','North');

/*  Which region placed the most orders? */

SELECT region,COUNT(order_id) AS total_orders FROM public.customers c JOIN 
public.orders o ON c.customer_id = o.customer_id
GROUP BY region ORDER BY total_orders DESC LIMIT 1;

/* Find regions with total sales greater than $10,000*/

SELECT region,SUM(unit_price * quantity) AS total_sales 
FROM public.customers c JOIN public.orders o ON o.customer_id = c.customer_id
JOIN public.order_details od ON od.order_id = o.order_id 
JOIN public.products p ON p.product_id = od.product_id
GROUP BY region HAVING SUM(unit_price * quantity) > 10000;
-- region wise and category wise sales
SELECT region,category,SUM(unit_price * quantity) AS total_sales 
FROM public.customers c JOIN public.orders o ON o.customer_id = c.customer_id
JOIN public.order_details od ON od.order_id = o.order_id 
JOIN public.products p ON p.product_id = od.product_id
group by region,category;
/*  Find the total sales per region, but:
	Only consider orders placed after Jan 1, 2023
	Only show regions where total sales > 5000 */
	
--region wise sales 
SELECT region, SUM(unit_price * quantity) AS sales FROM public.customers c
JOIN public.orders o ON o.customer_id = c.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id
GROUP  BY region ORDER BY region;

--sales from after Jan 1, 2023
SELECT  SUM(od.quantity * p.unit_price) AS total_sales_after_jan01
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE o.order_date >= '2023-01-01';

-- COMBINING BOTH CONDITIONS
SELECT region, SUM(unit_price * quantity) AS total_sales FROM public.customers c
JOIN public.orders o ON o.customer_id = c.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id
where o.order_date >= '2023-01-01'
group by region having  SUM(unit_price * quantity) > 5000;


/***********************************************************************/
				/**** GROUPING SETS ******/

SELECT region,category,
SUM(quantity*unit_price) AS sales_amount 
FROM public.customers c
JOIN public.orders o ON c.customer_id = o.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id
GROUP BY GROUPING SETS(region,category,(region,category),());
---------------------------------------

	/*************** CUBE ********************/
	
SELECT region,category,
SUM(quantity*unit_price) AS sales_amount 
FROM public.customers c
JOIN public.orders o ON c.customer_id = o.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id

GROUP BY CUBE(region,category)--grouping sets((region,category),region,category,())
ORDER BY region,category;
 
	/************ ROLL UP ***********/
SELECT region,category,
SUM(quantity*unit_price) AS sales_amount 
FROM public.customers c
JOIN public.orders o ON c.customer_id = o.customer_id
JOIN public.order_details od ON od.order_id = o.order_id
JOIN public.products p ON p.product_id = od.product_id
GROUP BY ROLLUP (region,category);

	/************** SET OPERATIONS ****************/
			/****** UNION ******/
		
SELECT customer_id  FROM public.customers
UNION 
SELECT product_id FROM public.products
ORDER BY customer_id;

SELECT customer_id as id,customer_name  FROM public.customers

UNION all
SELECT product_id, product_name FROM public.products
ORDER BY id

--UNION removes duplicates only if the entire row matches — across all selected columns.
--COLUMN NAMES, ALIASING, ORDER BY?
-- practical example?
		/****** UNION ALL ******/
SELECT  region FROM public.customers
UNION ALL
SELECT  category FROM public.products;
		
		/****** INTERSECT ******/
/* List the customers who have placed orders. */
SELECT customer_id FROM public.customers
INTERSECT 
SELECT customer_id FROM public.orders;
		
		/****** EXCEPT ******/
/* List the customers who have not placed any orders. */
SELECT customer_id FROM public.customers
EXCEPT 
SELECT customer_id FROM public.orders
---
--Examples for ROUND() & TYPE-CASTING
select round(unit_price::numeric,1) from products;
select 0.23456::text -- Invalid
select 1.23 :: int -- valid
