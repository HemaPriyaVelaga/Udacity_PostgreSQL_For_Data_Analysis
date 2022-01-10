-- SUB-QUERIES AND TEMPORARY TABLES

-- Both subqueries and table expressions are methods for being able to write
-- a query that creates a table, and then write a query that interacts with
-- this newly created table.

-- Whenever we need to use existing tables to create a new table that we then
-- want to query again, this is an indication that we will need to use some sort
-- of subquery

-- First, inner query will be executed, and then, the rest of the query will be
-- executed on the result set returned by the inner subquery


-- Example: FInd avg events per channel per day
SELECT channel, AVG(event_count) avg_event_per_channel
FROM
    (SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(*) event_count
     FROM web_events GROUP BY 1, 2) sub
GROUP BY 1
ORDER BY 2 DESC;


-- if you are only returning a single value, you might use that value in a
-- logical statement like WHERE, HAVING, or even SELECT - the value could be
-- nested within a CASE statement.
-- Note that you should not include an alias when you write a subquery in a
-- conditional statement because the subquery is treated as an individual value
-- (or set of values in the IN case) rather than as a table.


-- Avg amount of each paper type sold in the first month of the business
SELECT AVG(avg_std) std_avg, AVG(avg_poster) poster_avg, AVG(avg_gloss) gloss_avg
FROM
    (SELECT id, occurred_at, AVG(standard_qty) avg_std, AVG(poster_qty) avg_poster, AVG(gloss_qty) avg_gloss
     FROM orders
     GROUP BY id, occurred_at
     HAVING DATE_TRUNC('month', occurred_at) =
            (SELECT DATE_TRUNC('month', MIN(occurred_at))
             FROM orders)
     ORDER BY 2) new_table;
-- OR
SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);



-- Q1. Provide the name of the sales_rep in each region with the largest amount
-- of total_amt_usd sales.
SELECT t3.sales_rep, t3.region, t3.total_sales_per_rep
FROM (SELECT region, MAX(total_sales_per_rep) max_sales_amt
      FROM (SELECT r.name region, s.name sales_rep, SUM(o.total_amt_usd) total_sales_per_rep
            FROM region r                                                                                                                                           JOIN sales_reps s ON s.region_id = r.id
            JOIN accounts a ON a.sales_rep_id = s.id
            JOIN orders o ON a.id = o.account_id
            GROUP BY sales_rep, region) t1
      GROUP BY region) t2
JOIN
    (SELECT r.name region, s.name sales_rep, SUM(o.total_amt_usd) total_sales_per_rep
     FROM region r
     JOIN sales_reps s ON s.region_id = r.id
     JOIN accounts a ON a.sales_rep_id = s.id
     JOIN orders o ON a.id = o.account_id
     GROUP BY sales_rep, region) t3
ON t3.region = t2.region AND t2.max_sales_amt = t3.total_sales_per_rep;



-- Q2. For the region with the largest (sum) of sales total_amt_usd, how many
-- total (count) orders were placed?
SELECT t1.region, COUNT(o.id) num_orders
FROM orders o
JOIN accounts a ON a.id = o.account_id
JOIN sales_reps s ON s.id = a.sales_rep_id
JOIN region r ON r.id = s.region_id
JOIN (SELECT r.name region, SUM(o.total_amt_usd) total_sales
      FROM region r
      JOIN sales_reps s ON s.region_id = r.id
      JOIN accounts a ON a.sales_rep_id = s.id
      JOIN orders o ON a.id = o.account_id
      GROUP BY region
      ORDER BY total_sales DESC
      LIMIT 1) t1 -- t1 is to get the region with largest sales
ON r.name = t1.region
GROUP BY t1.region;



-- Q3. How many accounts had more total purchases than the account name which
-- has bought the most standard_qty paper throughout their lifetime as a customer?

-- t1 to get the name of the account who ordered max standard quantity
SELECT a.name, SUM(o.standard_qty) total_std_qty_purchased , SUM(o.total)
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC
LIMIT 1;

-- t2 to get the total orders of each account
SELECT a.name, SUM(o.total) total_qty
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name;

-- Final solution:
SELECT COUNT(*) FROM (SELECT a.name, SUM(o.total) total_qty
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name
HAVING SUM(o.total) > (SELECT total
                       FROM (SELECT a.name, SUM(o.standard_qty) total_std_qty_purchased, SUM(o.total) total
                             FROM orders o
                             JOIN accounts a ON a.id = o.account_id
                             GROUP BY a.name
                             ORDER BY 2 DESC
                             LIMIT 1) t1)
                       ) t2;




-- Q4. For the customer that spent the most (in total over their lifetime as a
-- customer) total_amt_usd, how many web_events did they have for each channel?

-- t1 gives the customer with max total_amt_usd
SELECT a.name, SUM(o.total_amt_usd) max_total
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC
LIMIT 1;

-- t2 gives the count of web events per channel per customer
SELECT a.name, w.channel, COUNT(w.id)
FROM accounts a
JOIN web_events w ON w.account_id = a.id
GROUP BY a.name,w.channel
ORDER BY 1;

-- Final solution
SELECT a.name, w.channel, COUNT(w.id) num_web_events
FROM accounts a
JOIN web_events w ON w.account_id = a.id
GROUP BY a.name,w.channel
HAVING a.name = (SELECT name
                 FROM (SELECT a.name, SUM(o.total_amt_usd) max_total
                       FROM orders o
                       JOIN accounts a ON a.id = o.account_id
                       GROUP BY a.name
                       ORDER BY 2 DESC
                       LIMIT 1) t1);




-- Q5 What is the lifetime average amount spent in terms of total_amt_usd for
-- the top 10 total spending accounts?

-- t1 gives the top 10 spending accounts
SELECT a.name, SUM(o.total_amt_usd) total_amt_spent
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC
LIMIT 10;

-- To find the average amount spent by each of the 10 accounts
--(not relevant to this question)
SELECT a.name, AVG(o.total_amt_usd) avg_amt_spent
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
HAVING a.name IN (SELECT name
                  FROM (SELECT a.name, SUM(o.total_amt_usd) total_amt_spent
                        FROM orders o
                        JOIN accounts a ON a.id = o.account_id
                        GROUP BY a.name
                        ORDER BY 2 DESC
                        LIMIT 10) t1);

-- Final solution
SELECT AVG(top_ten_total_amt_spent)
FROM (SELECT a.name, SUM(o.total_amt_usd) top_ten_total_amt_spent
      FROM orders o
      JOIN accounts a ON a.id = o.account_id
      GROUP BY a.name
      HAVING a.name IN (SELECT name
                        FROM (SELECT a.name, SUM(o.total_amt_usd) total_amt_spent
                              FROM orders o
                              JOIN accounts a ON a.id = o.account_id
                              GROUP BY a.name
                              ORDER BY 2 DESC
                              LIMIT 10) t1)
                       ) t2;




-- Q6. What is the lifetime average amount spent in terms of total_amt_usd,
-- including only the companies that spent more per order, on average,
-- than the average of all orders.

-- t1 gives avg of all orders
SELECT AVG(o.total_amt_usd) avg_all_orders
FROM orders o;

-- t2 gives avg amount per order by each account
SELECT a.name, AVG(o.total_amt_usd) avg_amt_per_order
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name
ORDER BY 2 DESC;

-- t3 gives the total amount spent by all the companies whose average amount per
-- order is greateer than the total average
SELECT a.name, SUM(o.total_amt_usd) amt_per_order
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all_orders
                               FROM orders o)
ORDER BY 2 DESC;


-- Final solution
SELECT AVG(amt_per_order) avg_amt_spent_top_companies
FROM (SELECT a.name, AVG(o.total_amt_usd) amt_per_order
      FROM orders o
      JOIN accounts a ON o.account_id = a.id
      GROUP BY a.name
      HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all_orders
                                     FROM orders o)
      ORDER BY 2 DESC) t2;




-- ============================================================================
-- ============================================================================

-- WITH

-- The WITH statement is often called a Common Table Expression or CTE
-- Though these expressions serve the exact same purpose as subqueries,
-- they are more common in practice, as they tend to be cleaner
-- for a future reader to follow the logic.


-- Ex: Find avg events per channel per day
-- the below is a CTE. CTEs should be defined at the beginning of a query to be
-- able to be used in the later part of the query
-- events is the alias name of the CTE
WITH events AS (SELECT DATE_TRUNC('day', occurred_at) day, channel, COUNT(*) event_count
                FROM  web_events
                GROUP BY 1,2)
SELECT channel, AVG(event_count) avg_event_count
FROM web_events
GROUP BY 1
ORDER BY 2 DESC;

-- You can add more and more tables using the WITH statement in the same way

-- Syntactical Example
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)

SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;


-- Q1 Provide the name of the sales_rep in each region with the largest amount
-- of total_amt_usd sales.
WITH t1 AS (SELECT r.name region, s.name sales_rep, SUM(o.total_amt_usd) total_sales_per_rep
            FROM region r                                                                                                                                           JOIN sales_reps s ON s.region_id = r.id
            JOIN accounts a ON a.sales_rep_id = s.id
            JOIN orders o ON a.id = o.account_id
            GROUP BY sales_rep, region),

    t2 AS (SELECT region, MAX(total_sales_per_rep) max_sales_amt
           FROM t1 GROUP BY region)

SELECT t1.sales_rep, t1.region, t1.total_sales_per_rep
FROM t2
JOIN t1 ON t1.region = t2.region AND t2.max_sales_amt = t1.total_sales_per_rep;



-- Q2 For the region with the largest sales total_amt_usd, how many total
-- orders were placed?
WITH t1 AS (SELECT r.name region, SUM(o.total_amt_usd) total_sales
      FROM region r
      JOIN sales_reps s ON s.region_id = r.id
      JOIN accounts a ON a.sales_rep_id = s.id
      JOIN orders o ON a.id = o.account_id
      GROUP BY region
      ORDER BY total_sales DESC
      LIMIT 1)

SELECT t1.region, COUNT(o.id) num_orders
FROM orders o
JOIN accounts a ON a.id = o.account_id
JOIN sales_reps s ON s.id = a.sales_rep_id
JOIN region r ON r.id = s.region_id
JOIN t1 ON r.name = t1.region
GROUP BY t1.region;



-- Q3 How many accounts had more total purchases than the account name which has
-- bought the most standard_qty paper throughout their lifetime as a customer?
WITH t1 AS (SELECT a.name, SUM(o.standard_qty) total_std_qty_purchased, SUM(o.total) total
                             FROM orders o
                             JOIN accounts a ON a.id = o.account_id
                             GROUP BY a.name
                             ORDER BY 2 DESC
                             LIMIT 1),

     t2 AS (SELECT a.name, SUM(o.total) total_qty
            FROM orders o
            JOIN accounts a ON o.account_id = a.id
            GROUP BY a.name
            HAVING SUM(o.total) > (SELECT total FROM t1))

SELECT COUNT(*) FROM t2;



-- Q4. For the customer that spent the most (in total over their lifetime as a
-- customer) total_amt_usd, how many web_events did they have for each channel?
WITH t1 AS (SELECT a.name, SUM(o.total_amt_usd) max_total
            FROM orders o
            JOIN accounts a ON a.id = o.account_id
            GROUP BY a.name
            ORDER BY 2 DESC
            LIMIT 1)

SELECT a.name, w.channel, COUNT(w.id) num_web_events
FROM accounts a
JOIN web_events w ON w.account_id = a.id
GROUP BY a.name,w.channel
HAVING a.name = (SELECT name
                 FROM t1);



-- Q5. What is the lifetime average amount spent in terms of total_amt_usd for
-- the top 10 total spending accounts?
WITH t1 AS (SELECT a.name, SUM(o.total_amt_usd) total_amt_spent
            FROM orders o
            JOIN accounts a ON a.id = o.account_id
            GROUP BY a.name
            ORDER BY 2 DESC
            LIMIT 10),

t2 AS (SELECT a.name, SUM(o.total_amt_usd) top_ten_total_amt_spent
      FROM orders o
      JOIN accounts a ON a.id = o.account_id
      GROUP BY a.name
      HAVING a.name IN (SELECT name
                        FROM t1))

SELECT AVG(top_ten_total_amt_spent)
FROM t2;

-- OR
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;



-- Q6. What is the lifetime average amount spent in terms of total_amt_usd,
-- including only the companies that spent more per order, on average,
-- than the average of all orders.
WITH t1 AS (SELECT AVG(o.total_amt_usd) avg_all_orders
            FROM orders o),

    t2 AS (SELECT a.name, AVG(o.total_amt_usd) amt_per_order
           FROM orders o
           JOIN accounts a ON o.account_id = a.id
           GROUP BY a.name
           HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1)
           ORDER BY 2 DESC)

SELECT AVG(amt_per_order) avg_amt_spent_top_companies
FROM t2;


-- CTEs are more efficient, as the tables are not recreated with each subquery portion
