-- Total number of orders placed?

SELECT 
    COUNT(ID) AS TOTAL_ORDERS
FROM
    ORDERS;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY),2) AS REVENUE
FROM
    PIZZAS
JOIN
    ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID;
    
 -- Identify the highest-priced pizza.
SELECT 
    PIZZA_TYPES.NAME, PIZZAS.PRICE
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
ORDER BY PRICE DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    PIZZAS.SIZE, COUNT(ORDER_DETAILS.QUANTITY) TOTAL_ORDERS
FROM
    ORDER_DETAILS
        JOIN
    PIZZAS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY SIZE;

 --  top 5 most ordered pizza types along with their quantities.
SELECT 
    PIZZA_TYPES.NAME,
    SUM(ORDER_DETAILS.QUANTITY) AS TOTAL_QUANTITY
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.NAME
ORDER BY 2 DESC
LIMIT 5;

-- Find the total quantity of each pizza category ordered.
 SELECT 
    PIZZA_TYPES.CATEGORY,
    SUM(ORDER_DETAILS.QUANTITY) AS TOTAL_QUANTITY
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 1;

-- Distribution of orders by hour of the day.
SELECT 
    HOUR(ORDER_TIME), COUNT(ID) AS ORDER_COUNT
FROM
    ORDERS
GROUP BY 1;

 -- the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(QUANTITY),2) AS AVG_ORDERS_PER_DAY
FROM
    (SELECT 
        ORDERS.ORDER_DATE, SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
    FROM
        ORDERS
    JOIN ORDER_DETAILS ON ORDERS.ID = ORDER_DETAILS.ID
    GROUP BY 1) AS SUBQ;

-- Determine the top 5 most ordered pizza types based on revenue.

SELECT 
    PIZZA_TYPES.NAME,
    ROUND(SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY),2) AS REVENUE
FROM
    PIZZAS
        JOIN
    ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
        JOIN
    PIZZA_TYPES ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; 
  
-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    PIZZA_TYPES.Name, ROUND(SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY),2) AS Revenue,
	(SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY)/
		(SELECT SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY)
		 FROM PIZZAS
		 JOIN
    ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
    JOIN PIZZA_TYPES ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID))*100 AS Revenue_percentage
FROM
    PIZZAS
JOIN
    ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
    JOIN PIZZA_TYPES ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
    GROUP BY 1 ORDER BY 2 DESC;
    
 -- Find the cumulative revenue generated over time
 
SELECT ORDER_DATE, ROUND(SUM(REVENUE) OVER (ORDER BY ORDER_DATE),2) AS CUMULATIVE_REVENUE 
FROM
	(SELECT ORDERS.ORDER_DATE, SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY) AS REVENUE 
FROM ORDERS JOIN ORDER_DETAILS ON ORDERS.ID = ORDER_DETAILS.ID
JOIN PIZZAS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
GROUP BY 1) AS SUBQUERY;

-- Find the top 3 most ordered pizza types based on revenue for each pizza category
 SELECT NAME, CATEGORY, REVENUE FROM
	(SELECT NAME, CATEGORY, REVENUE, 
	RANK() OVER (PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RANKS 
	FROM
		(SELECT PIZZA_TYPES.NAME, PIZZA_TYPES.CATEGORY, SUM(PIZZAS.PRICE * ORDER_DETAILS.QUANTITY) AS REVENUE 
		FROM PIZZA_TYPES JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
		JOIN ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
		GROUP BY 1,2) AS SUBQ) 
	AS SUBQ2
WHERE RANKS <=3;

-- Rank each pizza category based on the total revenue

SELECT CATEGORY, TOTAL_REVENUE,
       RANK() OVER (ORDER BY TOTAL_REVENUE DESC) AS CATEGORY_RANK
FROM (
    SELECT PIZZA_TYPES.CATEGORY, ROUND(SUM(PIZZAS.PRICE *ORDER_DETAILS.QUANTITY),2) AS TOTAL_REVENUE 
    FROM PIZZA_TYPES JOIN PIZZAS ON  PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
    JOIN  ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
    GROUP BY 1
) AS CATEGORY_REVENUE;

-- revenue generated for each month.

SELECT 
    MONTH(order_date) AS month,
    ROUND(SUM(price * quantity), 2) AS revenue
FROM
    orders
        JOIN
    order_details ON orders.id = order_details.id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY MONTH(order_date)
ORDER BY 2 DESC;


 -- REVENUE OVER TIME (FOR VISUALIZATION)
 
SELECT 
    ORDER_TIME,
    ROUND(SUM(price * quantity), 2) AS revenue
FROM
    orders
        JOIN
    order_details ON orders.id = order_details.id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1;





