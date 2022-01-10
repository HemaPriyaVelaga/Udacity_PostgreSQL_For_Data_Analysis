-- AGGREGATIONS
-- Ex: COUNT, SUM, MIN, MAX, AVG,
-- NULL is not a value but a property of data. So use, IS or IS NOT but not = or !=
SELECT SUM(poster_qty) FROM orders;

SELECT SUM(standard_qty) FROM orders;

SELECT SUM(total_amt_usd) FROM orders;

SELECT standard_amt_usd = gloss_amt_usd stg_gloss_amt FROM orders LIMIT 10;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) FROM orders;

-- Functionally, MIN and MAX are similar to COUNT in that
-- they can be used on non-numerical columns. Depending on
-- the column type, MIN will return the lowest number,
-- earliest date, or non-numerical value as early in the alphabet as possible.


SELECT MIN(occurred_at) earliest_order FROM orders;
-- same as the following (without aggregation function):
SELECT occurred_at earliest_order FROM orders ORDER BY occurred_at ASC LIMIT 1;


SELECT MAX(occurred_at) most_recent FROM web_events;
-- same as the following (without aggregation function):
SELECT occurred_at most_recent FROM web_events ORDER BY occurred_at DESC LIMIT 1;


-- ============================================================================
-- ============================================================================

-- GROUP BY
-- 1. Any column in the SELECT statement that is not within an aggregator
  -- must be in the GROUP BY clause.
-- 2. The GROUP BY always goes between WHERE and ORDER BY.


-- Q1. Which account (by name) placed the earliest order?
-- Your solution should have the account name and the date of the order.
-- Without aggregations:
SELECT a.name, o.occurred_at
FROM orders o
JOIN accounts a ON a.id = o.account_id
ORDER BY o.occurred_at ASC
LIMIT 1;


-- Q2. Find the total sales in usd for each account. You should include
-- two columns - the total sales for each company's orders in usd and the company name.
-- With aggregation Function
SELECT a.name, SUM(o.total_amt_usd)
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name;


-- Q3. Via what channel did the most recent (latest) web_event occur,
-- which account was associated with this web_event? Your query should
-- return only three values - the date, channel, and account name.
-- Without AGGREGATION
SELECT a.name, w.occurred_at, w.channel
FROM web_events w
JOIN accounts a ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;


-- Q4. Find the total number of times each type of channel from the
-- web_events was used. Your final table should have two columns -
-- the channel and the number of times the channel was used.
-- With AGGREGATION
SELECT channel, COUNT(*)
FROM web_events
GROUP BY channel;


-- Q5. Who was the primary contact associated with the earliest web_event?
-- Without aggregation
SELECT a.name, w.occurred_at, w.channel, a.primary_poc
FROM web_events w
JOIN accounts a ON a.id = w.account_id
ORDER BY w.occurred_at ASC
LIMIT 1;


-- Q6. What was the smallest order placed by each account in terms of
-- total usd. Provide only two columns - the account name and the total usd.
-- Order from smallest dollar amounts to largest.
-- With aggregation functions
SELECT a.name, MIN(o.total) min_total_order
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY min_total_order;


-- Q7. Find the number of sales reps in each region. Your final table
-- should have two columns - the region and the number of sales_reps.
-- Order from fewest reps to most reps.
-- With Aggregation functions
SELECT r.name, COUNT(*) num_sales_reps
FROM region r
JOIN sales_reps s ON s.region_id = r.id
GROUP BY r.name
ORDER BY num_sales_reps;


-- =========================================================================
-- =========================================================================

-- GROUP BY MULTIPLE COLUMNS

-- The order of columns listed in the ORDER BY clause does make a difference.
    -- You are ordering the columns from left to right.

-- The order of column names in your GROUP BY clause doesn’t matter—
    -- the results will be the same regardless. If we run the same query and
    -- reverse the order in the GROUP BY clause, you can see we get the same
    -- results.

-- Q1. For each account, determine the average amount of each type of paper
-- they purchased across their orders. Your result should have four columns -
-- one for the account name and one for the average quantity purchased for
-- each of the paper types for each account.
SELECT a.name, AVG(o.standard_qty) avg_std_qty, AVG(o.poster_qty) avg_poster_qty, AVG(o.gloss_qty) avg_gloss_qty
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
LIMIT 10;


-- Q2. For each account, determine the average amount spent per order on
-- each paper type. Your result should have four columns - one for the
-- account name and one for the average amount spent on each paper type.
SELECT a.name, AVG(o.standard_amt_usd)/AVG(o.standard_qty) avg_amt_per_std_order,
      AVG(o.poster_amt_usd)/AVG(o.poster_qty) avg_amt_per_poster_order,
      AVG(o.gloss_amt_usd)/AVG(o.gloss_qty) avg_amt_per_gloss_order
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
LIMIT 10;


-- Q3. Determine the number of times a particular channel was used in the
-- web_events table for each sales rep. Your final table should have three
-- columns - the name of the sales rep, the channel, and the number of
-- occurrences. Order your table with the highest number of occurrences first.
SELECT s.name, w.channel, COUNT(*) occurrences
FROM web_events w
JOIN accounts a ON w.account_id = a.id
JOIN sales_reps s ON s.id = a.sales_rep_id
GROUP BY w.channel, s.name
ORDER BY s.name, occurrences DESC;


-- Q4. Determine the number of times a particular channel was used in the
-- web_events table for each region. Your final table should have three columns
-- the region name, the channel, and the number of occurrences.
-- Order your table with the highest number of occurrences first.
SELECT r.name, w.channel, COUNT(*) occurrences
FROM web_events w
JOIN accounts a ON a.id = w.account_id
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY r.name, occurrences DESC;



-- =========================================================================
-- =========================================================================

-- DISTINCT

-- We usually dont need groupby when we are not using aggregations
-- DISTINCT is always used in SELECT statements, and it provides
   -- the unique rows for ALL columns written in the SELECT statement.
   -- Therefore, you only use DISTINCT ONCE in any particular SELECT statement.
-- It’s worth noting that using DISTINCT, particularly in aggregations,
   -- can slow your queries down quite a bit.

-- Q1. Use DISTINCT to test if there are any accounts associated
-- with more than one region.
SELECT DISTINCT a.name, r.name
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
ORDER BY a.name;
-- OR
SELECT DISTINCT id, name
FROM accounts;


-- Q2. Have any sales reps worked on more than one account?
SELECT DISTINCT s.name, a.id
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
ORDER BY s.name;
-- OR
SELECT DISTINCT id, name
FROM sales_reps;


-- =========================================================================
-- =========================================================================

-- HAVING

-- Essentially, any time you want to perform a WHERE on an element of your
-- query that was created by an aggregate, you need to use HAVING instead.
-- Because WHERE clause doesnt allow filtering on aggregations

-- Q1. How many of the sales reps have more than 5 accounts that they manage?
SELECT sales_rep_id, COUNT(id)
FROM accounts
GROUP BY sales_rep_id
HAVING COUNT(id) > 5;

-- Q2. How many accounts have more than 20 orders?
SELECT account_id, COUNT(id)
FROM orders
GROUP BY account_id
HAVING COUNT(id)>20;

-- Q3. Which account has the most orders?
SELECT account_id, COUNT(id)
FROM orders
GROUP BY account_id
ORDER BY COUNT(id) DESC
LIMIT 1;

-- Q4. Which accounts spent more than 30,000 usd total across all orders?
SELECT account_id, SUM(total_amt_usd)
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd)>30000;

-- Q5. Which accounts spent less than 1,000 usd total across all orders?
SELECT account_id, SUM(total_amt_usd)
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd)<1000;

-- Q6. Which account has spent the most with us?
SELECT account_id, SUM(total_amt_usd)
FROM orders
GROUP BY account_id
ORDER BY SUM(total_amt_usd) DESC
LIMIT 1;

-- Q7. Which account has spent the least with us?
SELECT account_id, SUM(total_amt_usd)
FROM orders
GROUP BY account_id
ORDER BY SUM(total_amt_usd) ASC
LIMIT 1;

-- Q8. Which accounts used facebook as a channel to contact
-- customers more than 6 times?
SELECT a.name, COUNT(w.channel)
FROM accounts a
JOIN web_events w ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.name
HAVING COUNT(w.channel)>6
ORDER BY COUNT(w.channel) DESC;

-- Q9. Which account used facebook most as a channel?
SELECT a.name, COUNT(w.channel)
FROM accounts a
JOIN web_events w ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.name
HAVING COUNT(w.channel)>6
ORDER BY COUNT(w.channel) DESC
LIMIT 1;

-- Q10. Which channel was most frequently used by most accounts?
SELECT w.channel, COUNT(w.account_id)
FROM web_events w
GROUP BY w.channel
ORDER BY COUNT(w.account_id) DESC;
-- OR
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;






-- =========================================================================
-- =========================================================================

-- DATE FUNCTIONS

-- YYYY-MM-DD is the format of dates in databases
   -- in order to facilitate proper sorting and for truncation

-- DATE_TRUNC : allows you to truncate your date to a particular part of your
   -- date-time column. Common trunctions are second, day, week, month, quarter and year.

-- DATE_PART : can be useful for pulling a specific portion of a date, but
   -- notice pulling month or day of the week (dow) means that you are no
   -- longer keeping the years in order.

-- You can reference the columns in your select statement in GROUP BY and
-- ORDER BY clauses with numbers that follow the order they appear in the
-- select statement.
SELECT standard_qty, COUNT(*)
FROM orders
GROUP BY 1
ORDER BY 1;


-- Q1. Find the sales in terms of total dollars for all orders in each year,
-- ordered from greatest to least. Do you notice any trends in the yearly
-- sales totals?
SELECT DATE_TRUNC('year', occurred_at), SUM(total_amt_usd) -- DATE_PART can also be used
FROM orders
GROUP BY 1
ORDER BY 1 ASC;


-- Q2. Which month did Parch & Posey have the greatest sales in terms of
-- total dollars? Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at), SUM(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- For 2nd part of the question:
SELECT DATE_PART('month', occurred_at), COUNT(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


-- Q3. Which year did Parch & Posey have the greatest sales in terms of
-- total number of orders? Are all years evenly represented by the dataset?
SELECT DATE_PART('year', occurred_at), COUNT(*) total_num_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


-- Q4. Which month did Parch & Posey have the greatest sales in terms of
-- total number of orders? Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at), COUNT(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Q5. In which month of which year did Walmart spend the most on gloss paper
-- in terms of dollars?
SELECT a.name, DATE_TRUNC('month', o.occurred_at), SUM(o.gloss_amt_usd) amt_spent_on_gloss
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY 1, 2
HAVING a.name = 'Walmart'
ORDER BY 3 DESC;





-- =========================================================================
-- =========================================================================

-- CASE STATEMENTS

-- For derived COLUMNS

-- The CASE statement always goes in the SELECT clause.

-- CASE must include the following components: WHEN, THEN, and END.
   -- ELSE is an optional component to catch cases that didn’t meet any
   -- of the other previous CASE conditions.

-- You can make any conditional statement using any conditional operator
   -- (like WHERE) between WHEN and THEN. This includes stringing together
   -- multiple conditional statements using AND and OR.

-- Example: Create a column that divides the standard_amt_usd by the standard_qty
-- to find the unit price for standard paper for each order. Limit the results
-- to the first 10 orders, and include the id and account_id fields.
-- NOTE - you will be thrown an error with the correct solution to this question.
-- This is for a division by zero.
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;
-- the first part of the statement will catch any of those division by zero
-- values that were causing the error, and the other components will compute
-- the division as necessary.


-- Q1. Write a query to display for each order, the account ID, total amount
-- of the order, and the level of the order - ‘Large’ or ’Small’ - depending on
-- if the order is $3000 or more, or smaller than $3000.
SELECT id, account_id, total_amt_usd, CASE WHEN total_amt_usd > 3000 THEN 'Large'
                                           ELSE 'Small' END order_level
FROM orders;


-- Q2. Write a query to display the number of orders in each of three categories,
-- based on the total number of items in each order. The three categories are:
-- 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT CASE WHEN total<1000 THEN 'Less than 1000'
            WHEN total>=1000 AND total<2000 THEN 'Between 1000 and 2000'
            ELSE 'At Least 2000' END order_categories,
       COUNT(*) num_orders
FROM orders
GROUP BY order_categories;


-- Q3. We would like to understand 3 different levels of customers based on the
-- amount associated with their purchases. The top level includes anyone with a
-- Lifetime Value (total sales of all orders) greater than 200,000 usd. The
-- second level is between 200,000 and 100,000 usd. The lowest level is anyone
-- under 100,000 usd. Provide a table that includes the level associated with
-- each account. You should provide the account name, the total sales of all
-- orders for the customer, and the level. Order with the top spending customers
-- listed first.
SELECT a.name,SUM(o.total_amt_usd) total_sales,
       CASE WHEN SUM(o.total_amt_usd)>200000 THEN 'Top Level'
            WHEN SUM(o.total_amt_usd)>=100000 AND SUM(o.total_amt_usd)<=200000 THEN 'Second Level'
            ELSE 'Lowest Level' END level
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC;


-- Q4. We would now like to perform a similar calculation to the first, but
-- we want to obtain the total amount spent by customers only in 2016 and 2017.
-- Keep the same levels as in the previous question. Order with the top spending
-- customers listed first.
SELECT a.name, DATE_PART('year', o.occurred_at), SUM(o.total_amt_usd) total_sales,
       CASE WHEN SUM(o.total_amt_usd)>200000 THEN 'Top Level'
            WHEN SUM(o.total_amt_usd)>=100000 AND SUM(o.total_amt_usd)<=200000 THEN 'Second Level'
            ELSE 'Lowest Level' END level
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name, o.occurred_at
HAVING DATE_PART('year', o.occurred_at) BETWEEN 2016 AND 2017
ORDER BY 3 DESC;


-- Q5. We would like to identify top performing sales reps, which are sales reps
-- associated with more than 200 orders. Create a table with the sales rep name,
-- the total number of orders, and a column with top or not depending on if they
-- have more than 200 orders. Place the top sales people first in your final table.
SELECT s.name, COUNT(o.id) orders,
       CASE WHEN COUNT(o.id)>200 THEN 'top'
            ELSE 'not' END performance
FROM orders o
JOIN accounts a ON o.account_id = a.id
JOIN sales_reps s ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY performance DESC, orders DESC;


-- Q6. The previous didn't account for the middle, nor the dollar amount
-- associated with the sales. Management decides they want to see these
-- characteristics represented as well. We would like to identify top performing
-- sales reps, which are sales reps associated with more than 200 orders or
-- more than 750000 in total sales. The middle group has any rep with more than
--  150 orders or 500000 in sales. Create a table with the sales rep name, the
-- total number of orders, total sales across all orders, and a column with top,
-- middle, or low depending on this criteria. Place the top sales people based
-- on dollar amount of sales first in your final table. You might see a few upset
-- sales people by this criteria!
SELECT s.name, COUNT(o.id) orders, SUM(o.total_amt_usd) total_sales,
       CASE WHEN COUNT(o.id)>200 OR SUM(o.total_amt_usd)>750000 THEN 'top'
            WHEN (COUNT(o.id)<=200 AND COUNT(o.id)>150) OR (SUM(o.total_amt_usd)<=750000 AND SUM(o.total_amt_usd)>500000) THEN 'middle'
            ELSE 'not' END performance
FROM orders o
JOIN accounts a ON o.account_id = a.id
JOIN sales_reps s ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC, orders DESC;
