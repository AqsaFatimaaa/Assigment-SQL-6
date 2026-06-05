-- ============================================================
--  HOMEWORK: Indexes & Stored Procedures
--  Topic   : SQL Indexes + Stored Procedures
--  Level   : Beginner to Intermediate
-- ============================================================


-- ============================================================
--  PART A: INDEXES
-- ============================================================

-- Q1.
-- Write a query to create a non-clustered index on the
-- last_name column of sales.customers.
-- Then write a SELECT statement that would benefit from it.
-- Hint: Think about which queries filter by last name.

CREATE NONCLUSTERED INDEX IX_Customers_LastName
ON sales.customers(last_name);



select customer_id,
   first_name,
   last_name
   from sales.customers
   where last_name='Brown';





-- Q2.
-- Create a composite index on sales.orders using
-- customer_id and order_date.
-- Write a query that filters on both columns and benefits
-- from this index.
-- Hint: Composite indexes work best when you filter on both columns.


CREATE NONCLUSTERED INDEX IX_Orders_Customer_OrderDate
ON sales.orders(customer_id, order_date);

SELECT order_id,
       customer_id,
       order_date
FROM sales.orders
WHERE customer_id = 10
  AND order_date >= '2018-01-01';



-- Q3.
-- A teammate suggests adding a unique index on
-- sales.customers(phone_number).
-- What could go wrong with this?
-- What assumption must be true for this to be safe?
-- Hint: Think about duplicate or missing (NULL) values.

-- Possible problems:
-- 1. Duplicate phone numbers may already exist.
-- 2. Some customers may have NULL phone numbers.
-- 3. Family members could share the same phone number.
--
-- For a UNIQUE index to be safe:
-- Every customer must have a unique phone number,
-- and data must be cleaned so no duplicates exist.



-- Q4.
-- Look at the columns below from a sales.orders table.
-- Decide which columns SHOULD have an index and which should NOT.
-- Explain your reasoning for each as a comment.
--
--   order_id     (Primary Key)
--   status       (only 3 values: Pending, Shipped, Delivered)
--   customer_id  (Foreign Key)
--   notes        (free text, rarely searched)

-- order_id (Primary Key)
-- YES
-- SQL Server automatically creates a clustered index
-- or unique index for the primary key.

-- status
-- NO
-- Only 3 possible values.
-- Low selectivity makes indexes less useful.

-- customer_id (Foreign Key)
-- YES
-- Frequently used in joins and searches.
-- Good candidate for indexing.

-- notes
-- NO
-- Large free-text column.
-- Rarely searched.
-- Regular index usually not useful.



-- Q5.
-- Write the command to check existing indexes on production.products.
-- Then describe (as a comment) what the output columns tell you.
-- Hint: Use sp_helpindex.

EXEC sp_helpindex 'production.products';

-- index_name
-- Name of the index.

-- index_description
-- Type of index (clustered, nonclustered, unique, etc.)

-- index_keys
-- Column(s) included in the index and their order.




-- ============================================================
--  PART B: STORED PROCEDURES
-- ============================================================

-- Q6.
-- Create a stored procedure called sp_GetCustomerOrders
-- that accepts a @CustomerID parameter and returns all orders
-- for that customer showing: order_id, order_date, order_status.
-- Test it using EXEC after you create it.

CREATE PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT order_id,
           order_date,
           order_status
    FROM sales.orders
    WHERE customer_id = @CustomerID;
END;
GO

EXEC sp_GetCustomerOrders @CustomerID = 5;

-- Q7.
-- Modify sp_GetCustomerOrders from Q6 so that if no orders
-- are found for the given customer, it returns the message:
-- 'No orders found for this customer'
-- Hint: Use IF EXISTS or check @@ROWCOUNT.

ALTER PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM sales.orders
        WHERE customer_id = @CustomerID
    )
    BEGIN
        SELECT order_id,
               order_date,
               order_status
        FROM sales.orders
        WHERE customer_id = @CustomerID;
    END
    ELSE
    BEGIN
        PRINT 'No orders found for this customer';
    END
END;
GO

EXEC sp_GetCustomerOrders 99999;

-- Q8.
-- Create a stored procedure sp_ProductsByCategory that accepts:
--   @CategoryID  INT
--   @MaxPrice    DECIMAL(10,2)  with a default value of 9999
-- It should return all matching products ordered by price (low to high).
-- Hint: Use a default parameter value like you saw with @threshold.

    CREATE PROCEDURE sp_ProductsByCategory
    @CategoryID INT,
    @MaxPrice DECIMAL(10,2) = 9999
AS
BEGIN
    SELECT product_id,
           product_name,
           list_price
    FROM production.products
    WHERE category_id = @CategoryID
      AND list_price <= @MaxPrice
    ORDER BY list_price ASC;
END;
GO

--Test

EXEC sp_ProductsByCategory @CategoryID = 2;

-- ============================================================
--  PART C: MIXED / THINK QUESTIONS
-- ============================================================

-- Q9.
-- You have a sales.orders table with 2 million rows.
-- A stored procedure filters by store_id and order_date.
-- It runs very slowly.
-- What TWO things would you do to fix it, and why?
-- Hint: Think about both indexes and procedure logic.

-- 1. Create an index on (store_id, order_date)
--
-- Example:
-- CREATE NONCLUSTERED INDEX IX_Orders_Store_Date
-- ON sales.orders(store_id, order_date);
--
-- This allows SQL Server to find matching rows quickly.

-- 2. Review procedure logic
--
-- Avoid:
--   SELECT *
--   unnecessary joins
--   functions on indexed columns
--
-- Return only required columns and write efficient filters.



-- Q10.
-- A junior developer creates indexes on EVERY column of a table
-- to "make everything faster".
-- Write a short explanation (3-5 sentences) of why this is
-- actually a bad idea.
-- Hint: Think about how INSERT, UPDATE, and DELETE are affected.

-- Creating indexes on every column increases storage usage.
-- Every INSERT, UPDATE, and DELETE must also update all indexes,
-- which slows down data modification operations.
-- Too many indexes can confuse the query optimizer and increase
-- maintenance costs.
-- Indexes should only be created on columns frequently used in
-- WHERE, JOIN, ORDER BY, and GROUP BY clauses.



-- ============================================================
--  END OF HOMEWORK
-- ============================================================