-- FULL OUTER JOIN

-- Say you're an analyst at Parch & Posey and you want to see:
-- each account who has a sales rep and each sales rep that has an account
   -- (all of the columns in these returned rows will be full)
-- but also each account that does not have a sales rep and each sales rep
   -- that does not have an account (some of the columns in these returned
   -- rows will be empty)

SELECT *
FROM accounts
FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL;



-- ============================================================================
-- ============================================================================

-- JOINs with comparison

SELECT o.id, o.occurred_at order_date, events.*
FROM orders o
LEFT JOIN web_events events ON events.account_id = o.account_id
                            AND events.occurred_at < o.occurred_at
WHERE DATE_TRUNC('month', o.occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(o.occurred_at)) FROM orders)
ORDER BY o.account_id, o.occurred_at;


-- Q1. write a query that left joins the accounts table and the sales_reps
-- tables on each sale rep's ID number and joins it using the < comparison
-- operator on accounts.primary_poc and sales_reps.name. The query results
-- should be a table with three columns: the account name (e.g. Johnson
-- Controls), the primary contact name (e.g. Cammy Sosnowski), and the sales
-- representative's name (e.g. Samuel Racine)
SELECT a.name account_name, a.primary_poc primary_contact_name, s.name sales_rep_name
FROM accounts a
LEFT OUTER JOIN sales_reps s ON a.sales_rep_id = s.id
                             AND a.primary_poc < s.name;



-- ============================================================================
-- ============================================================================

-- SELF JOINs

-- Most of the times, we do this to find cases where there are two events that
  -- occure one after the another

--  Self JOIN is optimal when you want to show both parent and child
  -- relationships within a family tree.

-- Ex: Know which accounts made multiple orders within 30 days
-- One way to solve is to join the orders table onto itself with an inequality join
SELECT o1.id AS o1_id, o1.account_id AS o1_account_id,
       o1.occurred_at as o1_occurred_at, o2.id AS o2_id,
       o2.account_id AS o2_account_id, o2.occurred_at AS o2_occurred_at
FROM orders o1
LEFT JOIN orders o2 ON o1.account_id = o2.account_id
                    AND o2.occurred_at > o1.occurred_at
                    AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1_account_id, o1_occurred_at;


-- Q1. Modify the above query to perform same analysis except for the web_events
--  table. Also: change the interval to 1 day to find those web events that
-- occurred after, but not more than 1 day after, another web event And add a
-- column for the channel variable in both instances of the table in your query.
SELECT w1.id AS w1_id, w1.account_id AS w1_account_id,
       w1.occurred_at as w1_occurred_at, w2.id AS w2_id,
       w1.channel AS w1_channel,
       w2.account_id AS w2_account_id, w2.occurred_at AS w2_occurred_at,
       w2.channel AS w2_channel
FROM web_events w1
LEFT JOIN web_events w2 ON w1.account_id = w2.account_id
                    AND w2.occurred_at > w1.occurred_at
                    AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1_account_id, w1_occurred_at;






-- ============================================================================
-- ============================================================================

-- Appending data via UNIONS

-- The UNION operator is used to combine the result sets of 2 or more SELECT
  -- statements. It removes duplicate rows between the various SELECT statements.

-- Each SELECT statement within the UNION must have the same number of fields
  -- in the result sets with similar data types.

-- Typically, the use case for leveraging the UNION command in SQL is when a
  -- user wants to pull together distinct values of specified columns that are
  -- spread across multiple tables. For example, a chef wants to pull together
  -- the ingredients and respective aisle across three separate meals that are
  -- maintained in different tables.

-- There must be the same number of expressions in both SELECT statements.
  -- The corresponding expressions must have the same data type in the SELECT
  -- statements. For example: expression1 must be the same data type in both
  -- the first and second SELECT statement.

-- NOTE:
  -- UNION removes duplicate rows.
  -- UNION ALL does not remove duplicate rows.

-- SQL's two strict rules for appending data:
  -- Both tables must have the same number of columns.
  -- Those columns must have the same data types in the same order as the
  -- first table.

-- To perform operations on the combined dataset after union, we can use then
  -- UNION query as a subquery so that the combined results are treated as a
  -- single result set

SELECT channel, COUNT(*) sessions
FROM (
      SELECT *
      FROM web_events w1
      WHERE w1.channel = 'facebook'

      UNION ALL

      SELECT *
      FROM web_events w2
      WHERE w2.channel = 'direct'
) web_events
GROUP BY 1
ORDER BY 2 DESC;

-- OR

WITH web_events AS (
  SELECT *
  FROM web_events w1
  WHERE w1.channel = 'facebook'

  UNION ALL

  SELECT *
  FROM web_events w2
  WHERE w2.channel = 'direct'
)
SELECT channel, COUNT(*) sessions
FROM web_events
GROUP BY 1
ORDER BY 2 DESC;

-- Ex: When you want to determine all reasons students are late. Currently,
  -- each late reason is maintained within tables corresponding to the grade
  -- the student is in. The table with the students' information needs to
  -- be appended with the late reasons. It requires no aggregation or filter,
  -- but all duplicates need to be removed. So the final use case is the one
  -- where the UNION operator makes the most sense.

-- Q1. Write a query that uses UNION ALL on two instances (and selecting all
-- columns) of the accounts table.
SELECT COUNT(*) FROM(
                      SELECT *
                      FROM accounts a1

                      UNION ALL

                      SELECT *
                      FROM accounts a2) accounts;


-- Q2. Add a WHERE clause to each of the tables that you unioned in the query
-- above, filtering the first table where name equals Walmart and filtering
-- the second table where name equals Disney.
SELECT * FROM(
                      SELECT *
                      FROM accounts a1
                      WHERE name = 'Walmart'

                      UNION ALL

                      SELECT *
                      FROM accounts a2
                      WHERE name = 'Disney') accounts;

-- OR
SELECT *
FROM accounts
WHERE name = 'Walmart' OR name = 'Disney';


-- Q3. Perform the union in your Q1 query in a common table expression and name
--  it double_accounts. Then do a COUNT the number of times a name appears in
-- the double_accounts table. If you do this correctly, your query results
-- should have a count of 2 for each name.
WITH double_accounts AS (
                      SELECT *
                      FROM accounts a1

                      UNION ALL

                      SELECT *
                      FROM accounts a2)
SELECT name, COUNT(*)
FROM double_accounts
GROUP BY name;




-- ============================================================================
-- ============================================================================

-- PERFORMANCE TUNING

-- The way to make a query run faster, is to reduce the number of calculations
-- that need to be performed.

-- NOTE:
-- High level things that will effect the number of calculations a given query
-- will make :
  -- 1. Table Size - If query hits large tables.
  -- 2. JOINS - If query joins tables, substantially increasing row count
  -- 2. Aggregations might use more calculations. Ex: COUNT DISTINCT will Take
        -- much more time than normal COUNT as it must check the table for
        -- All the distinct values before performing the COUNT operations
  -- 3. DB dependent (softwate and optimisation) -
        -- a) If multiple queries are executed on the same DB at the
              -- time, it might affect our query performance
        -- b) different DBs are optimised for different tasks. Ex: Postgres
              -- is optimisedto read and write new rows quickly, while Redshift
              -- is optimised to perform fast aggregations



-- IMPROVING THE SPEED

-- 1. FILTERING THE DATA
      -- to include only the observations we need can DRAMATICALLY
      -- improve the query speed.

      -- a). If we have a time series dataset, limiting our query to a small time
             -- window can make our queries run much more quickly

      -- b). Testing your queries on a subset of data, finalizing your query, then
             -- removing the subset limitation is a sound strategy.

      -- c). When working with subqueries, limiting the amount of data you’re working
             -- with in the place where it will be executed first will have the
             --  maximum impact on query run time.
             -- In general, when working with sub-queries, we should make sure
             -- to limit the amount of data we are working with in the place
             -- where it will be executed first, in order for it to have maximum
             --  impact on a query runtime, which usually means putting limit
             -- in the sub-query and not in the outer query

-- 2. MAKE JOINS LESS COMPLICATED
      -- a).  Reduce the number of rows that are evaluated during a join

      -- b). It is better to reduce table sizes before joining them

      -- c). In queries which involve aggregations across tables, we can
             -- pre-aggregate the tables to be joined, will reduce the cost
             -- of the join substantially

-- 3. JOINing Sub-Queries to improve performance:
      -- Subqueries can be very helpful in improving the performance of Queries
      -- Aggregating tables in sub-queries and then join the pre-aggregated
         -- sub-queries improves performance by a significant amount when compared
         -- executing the entire functionality in a single main query.
         -- Ex: Consider the following single main query
         SELECT DATE_TRUNC('day', o.occurred_at) date,
                COUNT(DISTINCT a.sales_rep_id) active_sales_reps,
                COUNT(DISTINCT o.id) orders,
                COUNT(DISTINCT we.id) web_visits
         FROM accounts a
         JOIN orders o ON o.account_id = a.id
         JOIN web_events we ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
         GROUP BY 1
         ORDER BY 1 DESC;
         -- here, joining by date fields cause DATA EXPLOSION, i.e., we are
         -- joining every row on a given day from 1 table onto every row
         -- with the same day on the other table, so, the number of rows
         -- returned is very HUGE/ Because of this, we need to use COUNT DISTINCT
         -- instead of regular count to get accurate counts. The above query
         -- will join around 79k rows and then perform aggregation by
         -- COUNT DISTINCT. This takes a lot of time

         -- We can get the same result much more efficiently by aggregating the
         -- tables separately so that the counts are performed across far smaller
         -- datasets
         SELECT COALESCE(orders.date, web_events.date) AS date,
                orders.active_sales_reps, orders.orders, web_events.web_visits
         FROM (SELECT DATE_TRUNC('day', o.occurred_at) date,
                       COUNT(a.sales_rep_id) active_sales_reps,
                       COUNT(o.id) orders
                FROM accounts a
                JOIN orders o ON o.account_id = a.id
                GROUP BY 1) orders
         FULL JOIN (
                    SELECT DATE_TRUNC('day', we.occurred_at) date,
                           COUNT(we.id) web_visits
                    FROM web_events we
                    GROUP BY 1) web_events
               ON web_events.date = orders.date
          ORDER BY 1 DESC;
         -- The above query will join only 1k rows each from each of the table
         -- This is far better in terms of performance compared to the earlier
         -- query.

         -- NOTE : It’s also worth noting that the FULL JOIN and COUNT above
                   -- actually runs pretty fast—it’s the COUNT(DISTINCT) that
                   -- takes forever.

-- EXPLAIN keyword:
-- We can  add EXPLAIN at the beginning of any working query to get a sense of
-- how long it will take. Its not perfectly accurate but is useful.
-- Shows the order in which the query will be executed. It adds a measure of
-- cost where higher numbers means longer run time.

-- To get value out of this keyword,
  -- 1. Run explain on a query
  -- 2. Modify the part of the query which takes more cost
  -- 3. repeat 1 and find if there is any improvement
  -- 4. repeat all the above steps
