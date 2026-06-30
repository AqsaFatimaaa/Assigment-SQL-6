-- ================================================================================
-- INTERVIEW PREP: BikeStores Database - 15 Beginner-Friendly Questions
-- Focus: Basic SELECT, WHERE, JOIN, GROUP BY, Simple Window Functions
-- Difficulty: Beginner to Lower-Intermediate
-- ================================================================================

-- ================================================================================
-- QUESTION 1: Basic SELECT (Beginner)
-- ================================================================================
--
-- "Show all products from the production.products table.
--  Display only: product_name, model_year, list_price.
--  Order by list_price from highest to lowest."

select
[product_name],
[model_year],
[list_price]
from
[production].[products]
order by [list_price] Desc;


--
-- ================================================================================

-- ================================================================================
-- QUESTION 2: Filtering with WHERE (Beginner)
-- ================================================================================
--
-- "Find all customers who live in New York (state = 'NY').
--  Show their first name, last name, city, and state."

select
[first_name] +' '+ [last_name] as full_name,
[city],
[state]
from
[sales].[customers]
where [state]= 'NY'
--
-- ================================================================================

-- ================================================================================
-- QUESTION 3: Simple JOIN (Beginner)
-- ================================================================================
--
-- "Show all orders with customer names.
--  Display: order_id, order_date, customer first name, customer last name.
--  Order by order_date (newest first)."
--
-- ================================================================================

select
o.[order_date],
o.[order_id],
c.[first_name],
c.[last_name]
from [sales].[orders]o
INNER JOIN [sales].[customers]c
on c.customer_id=o.customer_id
Order by o.[order_date] Desc;
-- ================================================================================
-- QUESTION 4: Basic GROUP BY with COUNT (Beginner)
-- ================================================================================
--
-- "Count how many customers are in each state.
--  Show state name and number of customers.
--  Order by customer count from highest to lowest."

select
COUNT (customer_id) AS customer_count,
[state]
from
[sales].[customers]
Group by [state]
order by customer_count desc;


-- ================================================================================

-- ================================================================================
-- QUESTION 5: GROUP BY with SUM (Beginner-Intermediate)
-- ================================================================================
--
-- "Calculate total sales amount for each store.
--  Show store_name and total_sales.
--  (Hint: sales_amount = quantity * list_price * (1 - discount))"
--
-- ================================================================================

select
s.[store_name],
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
from[sales].[orders]o
INNER JOIN[sales].[order_items]oi
on o.[order_id]=oi.[order_id]
INNER JOIN [sales].[stores]s
on s.store_id=o.store_id
Group by s.store_name
order by total_sales desc;



-- ================================================================================
-- QUESTION 6: GROUP BY with AVG and HAVING (Beginner-Intermediate)
-- ================================================================================
--
-- "Find brands that have an average product price greater than $2000.
--  Show brand_name and average_price.
--  Only include brands with at least 3 products."
--
-- ================================================================================


 SELECT
    b.brand_name,
    AVG(p.list_price) AS average_price
FROM production.products p
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
GROUP BY
    b.brand_name
HAVING
    AVG(p.list_price) > 2000
    AND COUNT(p.product_id) >= 3
ORDER BY
    average_price DESC;


-- ================================================================================
-- QUESTION 7: Basic Window Function - ROW_NUMBER() (Intermediate)
-- ================================================================================
--
-- "Number all products from cheapest to most expensive.
--  Show product_name, list_price, and a row number column called 'price_rank'.
--  Cheapest product should be number 1."
select
[product_name],
[list_price],
ROW_NUMBER() OVER (ORDER BY list_price ASC) AS price_rank
from
[production].[products]
 

--
-- ================================================================================

-- ================================================================================
-- QUESTION 8: ROW_NUMBER() with PARTITION BY (Intermediate)
-- ================================================================================
--
-- "For each brand, number the products by price (most expensive first).
--  Show brand_name, product_name, list_price, and rank within brand.
--  The most expensive product in each brand should be number 1."
--
-- ================================================================================
select
b.[brand_name],
p.[product_name],
p.[list_price],
ROW_NUMBER() OVER(
PARTITION BY (b.brand_name)
ORDER By p.list_price DESC
) as rank_within_brand
from
[production].[products]p
INNER JOIN [production].[brands]b
ON b.brand_id = p.brand_id



-- ================================================================================
-- QUESTION 9: Basic Running Total with SUM() OVER() (Intermediate)
-- ================================================================================
--
-- "Calculate a running total of daily orders.
--  Show order_date, number of orders on that date, 
--  and cumulative total of orders so far.
--  Order by order_date."
--
-- ================================================================================

select
[order_date],
COUNT([order_id])AS DAILY_ORDER,
SUM(COUNT(order_id)) OVER(
Order by order_date
) as runining_total
from
[sales].[orders]
Group by order_date
Order by order_date;

-- ================================================================================
-- QUESTION 10: RANK() vs ROW_NUMBER() (Intermediate)
-- ================================================================================
--
-- "Use both ROW_NUMBER() and RANK() on products ordered by list_price DESC.
--  Show product_name, list_price, row_number, and rank.
--  What difference do you notice when there are ties?"
--
-- ================================================================================
select
[product_name],
[list_price],
ROW_NUMBER() Over (order by list_price Desc)as row_number,
RANK() Over (order by list_price Desc) as rank
from
[production].[products];


--ROW_NUMBER() ignores ties and assigns a unique number to every row, even if two or more rows have the same value.
--RANK() assigns the same rank to rows with equal values (ties). After the tied rows, the next rank is skipped.


-- ================================================================================
-- QUESTION 11: Multiple JOINs (Intermediate)
-- ================================================================================
--
-- "Show all order items with product and order information.
--  Display: order_id, order_date, product_name, quantity, list_price.
--  Only show orders from 2023."
--
-- ================================================================================

select
o.[order_id],
o.[order_date],
p.[product_name],
oi.[quantity],
oi.[list_price]
from
[sales].[orders]o
INNER JOIN [sales].[order_items]oi
on o.order_id = oi.order_id
INNER JOIN[production].[products]p
ON p.product_id = oi.product_id
where Year(o.order_date)=2023;

-- ================================================================================
-- QUESTION 12: Basic CASE Statement (Intermediate)
-- ================================================================================
--
-- "Categorize products by price:
--    Under $500 = 'Budget'
--    $500 to $2000 = 'Regular'
--    Over $2000 = 'Premium'
--  Show product_name, list_price, and price_category."
--
-- ================================================================================

select
[product_name],
[list_price],
CASE
When [list_price] < 500 Then 'Budget'
When [list_price] between 500 and 200 Then 'Regular'
Else 'Premium'
End as price_category
from
[production].[products]

-- ================================================================================
-- QUESTION 13: LAG() - Previous Row Access (Intermediate)
-- ================================================================================
--
-- "For each customer, show their order date and the date of their previous order.
--  Display: customer_id, order_id, order_date, previous_order_date.
--  If no previous order, show NULL."
--
-- ================================================================================
select
[customer_id],
[order_id],
[order_date],
LAG(order_date) over(
partition by
[customer_id]
order by [order_date] 
)as perivious_order_date
from
[sales].[orders];

-- ================================================================================
-- QUESTION 14: Finding Top N with Window Function (Intermediate)
-- ================================================================================
--
-- "Find the top 3 most expensive products in each category.
--  Show category_name, product_name, list_price, and rank.
--  Use RANK() for ranking."
--
-- ================================================================================

SELECT *
FROM
(
    SELECT
        c.category_name,
        p.product_name,
        p.list_price,
        RANK() OVER (
            PARTITION BY c.category_name
            ORDER BY p.list_price DESC
        ) AS rank
    FROM production.products p
    INNER JOIN production.categories c
        ON p.category_id = c.category_id
) AS RankedProducts
WHERE rank <= 3;

-- ================================================================================
-- QUESTION 15: Combined Query - Everything Learned (Intermediate)
-- ================================================================================
--
-- "Create a report showing:
--    1. Customer name
--    2. Total amount spent by that customer
--    3. Customer's rank by spending (1 = highest spender)
--    4. Price tier of customer (VIP if spent > $5000, Regular if $1000-$5000, New if < $1000)
--  Order by rank."
--
-- ================================================================================

SELECT
    customer_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS customer_rank,
    CASE
        WHEN total_spent > 5000 THEN 'VIP'
        WHEN total_spent BETWEEN 1000 AND 5000 THEN 'Regular'
        ELSE 'New'
    END AS price_tier
FROM
(
    SELECT
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.customers c
    INNER JOIN sales.orders o
        ON c.customer_id = o.customer_id
    INNER JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.first_name,
        c.last_name
) AS CustomerSales
ORDER BY customer_rank;

-- ================================================================================
-- END OF INTERVIEW QUESTIONS
-- ================================================================================