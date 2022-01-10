-- WINDOW FUNCTIONS

-- It allows to compare one row to another without doing any joins
-- Ex: Running total

-- A window function performs a calculation across a set of table rows that
   -- are somehow related to the current row

-- But unlike regular aggregate functions, use of a window function does not
   -- cause rows to become grouped into a single output row — the rows retain
   -- their separate identities.

-- NOTE: You can’t use window functions and standard aggregations in the same
   -- query. More specifically, you can’t include window functions in a
   -- GROUP BY clause.


-- EX: Q1. Calculate a running total (over time) of how much std_paper that parch&posey has sold
-- till date
SELECT standard_qty,
       SUM(standard_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders
-- SUM OVER - designates it as a window function
-- The above can be read as : Take the SUM of standard quantity, across all rows
-- leading up to a given row, in ORDER BY occurred_at

-- To get the running total at the beginning of each month
    -- To narrow the window from the entire dataset to individual groups within
    -- the dataset, we use PARTITION BY function
SELECT standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders
-- The above query groups and orders the reults by the month in which
-- transactions occurred. Within each month, it is ordered by occurred_at.
-- and the running total sums across that current row and all previous rows
-- of standard_qty
-- IN SIMPLE WORDS, the above query starts aggregation from the beginning of
-- a month to its end. For the next month, instead of continuing the aggregated
-- total, it starts afresh for that particular month

-- If we dont use ORDER BY above, each value in every month will be the sum of
-- all the standard_qty that has been used in that particular month

-- The ORDER and PARTITION define what is the desired window - the ordered subset
-- of data over which the calculations have to be done


-- Q2. Now, modify your query from the previous quiz to include partitions.
-- Still create a running total of standard_amt_usd (in the orders table)
-- over order time, but this time, date truncate occurred_at by year and
-- partition by that same year-truncated occurred_at variable.
-- Your final table should have three columns: One with the amount being added
-- for each row, one for the truncated date, and a final column with the
-- running total within each year.
SELECT standard_qty, DATE_TRUNC('year', occurred_at) AS year,
       SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('year', occurred_at)
                               ORDER BY occurred_at) running_total_over_year
FROM orders;


-- ============================================================================
-- ============================================================================

-- ROW_NUMBER() and RANK()

-- ROW_NUMBER() - displayes row num according to the ORDER BY
-- Ex: order by ID
SELECT id, account_id, occurred_at,
       ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM orders;

-- RANK()
SELECT id, account_id, DATE_TRUNC('month', occurred_at) AS month,
       RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS rank_num
FROM orders;
-- Rank skips some row numbers in order to give same rank to orders having same
-- month in the above query.
-- To prevent that and use all numbers continuously, use DENSE_RANK()


-- Q1. Ranking Total Paper Ordered by Account
-- Select the id, account_id, and total variable from the orders table,
-- then create a column called total_rank that ranks this total amount of paper
-- ordered (from highest to lowest) for each account using a partition.
-- Your final table should have these four columns.
SELECT id, account_id, total,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders




-- ============================================================================
-- ============================================================================

-- Aggregates in Window Functions: SUM, COUNT, AVERAGE, MIN, MAX


SELECT id, account_id, standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS avg_std_qty, -- running sum / running count
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS max_std_qty
FROM orders;

-- Compare the above with the following:

SELECT id, account_id, standard_qty,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders;

-- Removing ORDER BY just leaves an unordered partition; in our query's case,
-- each column's value is simply an aggregation (e.g., sum, count, average,
-- minimum, or maximum) of all the standard_qty values in its respective account_id.

-- Simpl way using aliasing:
SELECT id, account_id, standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER main_window AS dense_rank,
       SUM(standard_qty) OVER main_window AS sum_std_qty,
       COUNT(standard_qty) OVER main_window AS count_std_qty,
       AVG(standard_qty) OVER main_window AS avg_std_qty, -- running sum / running count
       MIN(standard_qty) OVER main_window AS min_std_qty,
       MAX(standard_qty) OVER main_window AS max_std_qty
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at));
-- The above line usually goes between the WHERE clause and the GROUP BY clause
-- If neither of those are present, simply put it after the FROM clause


-- Ex:
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders;
-- also, the same as
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at);





-- ============================================================================
-- ============================================================================

-- LAG, LEAD

-- To compare a row with preceeding or following row
-- LAG : Each row’s value in lag is pulled from the previous row
-- LEAD : Each row’s value in lead is pulled from the row after it.

SELECT account_id, standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_diff,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_diff

FROM (SELECT account_id, SUM(standard_qty) AS standard_sum
      FROM orders
      GROUP BY 1) sub;


-- Example 1: You have a sales dataset with the following data and need to
   -- compare how the market segments fare against each other on profits earned.

-- Example 2: You have an inventory dataset with the following data and need to
   -- compare the number of days elapsed between each subsequent order placed
   -- for Item A.

-- Q1.  Imagine you're an analyst at Parch & Posey and you want to determine
-- how the current order's total revenue ("total" meaning from sales of all
-- types of paper) compares to the next order's total revenue.
SELECT occurred_at, total_sum,
       LEAD(total_sum) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_sum) OVER (ORDER BY occurred_at) - total_sum AS lead_diff
FROM (SELECT occurred_at, SUM(total_amt_usd) total_sum
      FROM orders
      GROUP BY 1) sub;


-- ============================================================================
-- ============================================================================

-- PERCENTILES using NTILE window function

-- You can use window functions to identify what percentile (or quartile, or
-- any other subdivision) a given row falls into.
-- The syntax is NTILE(*number of buckets*)


-- NOTE: In cases with relatively few rows in a window, the NTILE function
-- doesn’t calculate exactly as you might expect. For example, If you only
-- had two records and you were measuring percentiles, you’d expect one
-- record to define the 1st percentile, and the other record to define the
-- 100th percentile. Using the NTILE function, what you’d actually see is one
-- record in the 1st percentile, and one in the 2nd percentile.

-- In other words, when you use a NTILE function but the number of rows in
-- the partition is less than the NTILE(number of groups), then NTILE will
-- divide the rows into as many groups as there are members (rows) in the set
-- but then stop short of the requested number of groups. If you’re working
-- with very small windows, keep this in mind and consider using quartiles or
-- similarly small bands.

SELECT id, account_id, occurred_at, standard_qty,
       NTILE(4) OVER (ORDER BY standard_qty) AS quartile,
       NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
       NTILE(100) OVER (ORDER BY standard_qty) AS percentile,
FROM orders
ORDER BY standard_qty DESC;


-- Q1. Use the NTILE functionality to divide the accounts into 4 levels in
-- terms of the amount of standard_qty for their orders. Your resulting table
-- should have the account_id, the occurred_at time for each order, the total
-- amount of standard_qty paper purchased, and one of four levels in a
-- standard_quartile column.
SELECT account_id, occurred_at, standard_qty,
       NTILE(4) OVER(ORDER BY standard_qty) standard_quartile
FROM orders
ORDER BY 1 DESC;


-- Q2. Use the NTILE functionality to divide the accounts into two levels in
-- terms of the amount of gloss_qty for their orders. Your resulting table
-- should have the account_id, the occurred_at time for each order, the total
-- amount of gloss_qty paper purchased, and one of two levels in a gloss_half
-- column.
SELECT account_id, occurred_at, gloss_qty,
       NTILE(2) OVER(PARTITION BY account_id ORDER BY gloss_qty) gloss_half 
FROM orders
ORDER BY 1 DESC;


-- Q3. Use the NTILE functionality to divide the orders for each account into
-- 100 levels in terms of the amount of total_amt_usd for their orders. Your
-- resulting table should have the account_id, the occurred_at time for each
-- order, the total amount of total_amt_usd paper purchased, and one of 100
-- levels in a total_percentile column.
-- (IF WE SUM UP TOTAL FOR EACH ACCOUNT)
SELECT account_id, SUM(total_amt_usd) accnt_total_usd,
       NTILE(100) OVER(PARTITION BY account_id ORDER BY SUM(total_amt_usd)) total_percentile
FROM orders
GROUP BY account_id
ORDER BY 1 DESC;
-- OR (without summim up total for each account)
SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
  FROM orders
 ORDER BY account_id DESC
