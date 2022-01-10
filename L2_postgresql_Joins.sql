-- JOINS

SELECT orders.*, accounts.* -- same as SELECT *
FROM orders
JOIN accounts ON orders.account_id = accounts.id;


-- Joining 3 tables
SELECT *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id



-- ALIASES
-- While aliasing tables is the most common use case. It can also be used
-- to alias the columns selected to have the resulting table
-- reflect a more readable name.


-- Q1. Provide a table for all web_events associated with account name
-- of Walmart. There should be three columns. Be sure to include the
-- primary_poc, time of the event, and the channel for each event.
-- Additionally, you might choose to add a fourth column to assure
-- only Walmart events were chosen.
SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';
-- In the above query, if you use AND instead of WHERE, the table is first
-- filtered and then a new filtered table is joined  with the other table
-- Otherwise, both the tables will be joined and then filtered.


-- Q2. Provide a table that provides the region for each sales_rep
-- along with their associated accounts. Your final table should include
-- three columns: the region name, the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to account name.
SELECT s.name sales_rep_name, r.name region, a.name account_name
FROM sales_reps s
JOIN region r ON s.region_id = r.id
JOIN accounts a ON s.id = a.sales_rep_id
ORDER BY a.name ASC;


-- Q3. Provide the name for each region for every order, as well as
-- the account name and the unit price they paid (total_amt_usd/total)
-- for the order. Your final table should have 3 columns: region name,
-- account name, and unit price. A few accounts have 0 for total,
-- so I divided by (total + 0.01) to assure not dividing by zero.
SELECT sr.name region_name, a.name account_name, (o.total_amt_usd/(o.total + 0.01)) unit_price_paid
FROM accounts a
JOIN orders o ON a.id = o.account_id
JOIN
  (SELECT s.id sr_id, s.region_id region_id, r.name
    FROM sales_reps s
    JOIN region r ON s.region_id = r.id)
  sr ON a.sales_rep_id = sr.sr_id;

  -- OR

  SELECT r.name region, a.name account,
         o.total_amt_usd/(o.total + 0.01) unit_price
  FROM region r
  JOIN sales_reps s
  ON s.region_id = r.id
  JOIN accounts a
  ON a.sales_rep_id = s.id
  JOIN orders o
  ON o.account_id = a.id;


-- LEFT JOIN:
  -- SELECT FROM lefttable LEFT JOIN righttable
-- it is the same as SELECT FROM righttable RIGHT JOIN lefttable
-- LEFT and RIGHT join are interchangeable so we will mostly use
-- LEFT joins in this course
-- If there is not matching information in the JOINed table, then you will
-- have columns with empty cells. These empty cells introduce a new data
-- type called NULL.
-- LEFT JOIN == LEFT OUTER JOIN and RIGHT JOIN == RIGHT OUTER JOIN
-- FULL OUTER JOIN == OUTER JOIN
-- UNION, UNION ALL, CROSS JOIN, SELF JOIN


-- Q1. Provide a table that provides the region for each sales_rep
-- along with their associated accounts. This time only for the
-- Midwest region. Your final table should include three columns:
-- the region name, the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to account name.
SELECT s.name sales_reps_name, r.name region_name, a.name account_name
FROM sales_reps s
JOIN region r ON s.region_id = r.id AND r.name = 'Midwest'
JOIN accounts a ON s.id = a.sales_rep_id
ORDER BY a.name ASC;
-- OR
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name;


-- Q2. Provide a table that provides the region for each sales_rep
-- along with their associated accounts. This time only for accounts
-- where the sales rep has a first name starting with S and in the
-- Midwest region. Your final table should include three columns:
-- the region name, the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to account name.
SELECT s.name sales_reps_name, r.name region_name, a.name account_name
FROM sales_reps s
JOIN region r ON s.region_id = r.id AND r.name = 'Midwest'
JOIN accounts a ON s.id = a.sales_rep_id AND s.name LIKE 'S%'
ORDER BY a.name ASC;
--OR
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;


-- Q3. Provide a table that provides the region for each sales_rep
-- along with their associated accounts. This time only for accounts
-- where the sales rep has a last name starting with K and in the
-- Midwest region. Your final table should include three columns:
-- the region name, the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to account name.
SELECT s.name sales_reps_name, r.name region_name, a.name account_name
FROM sales_reps s
JOIN region r ON s.region_id = r.id AND r.name = 'Midwest'
JOIN accounts a ON s.id = a.sales_rep_id AND s.name LIKE '% K%'
ORDER BY a.name ASC;
--OR
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name;


-- Q4. Provide the name for each region for every order, as well as
-- the account name and the unit price they paid (total_amt_usd/total)
-- for the order. However, you should only provide the results if the
-- standard order quantity exceeds 100. Your final table should have
-- 3 columns: region name, account name, and unit price. In order to
-- avoid a division by zero error, adding .01 to the denominator
-- here is helpful total_amt_usd/(total+0.01).
SELECT a.name account_name, r.name region_name, o.total_amt_usd/(o.total + 0.01) unit_price
FROM accounts a
JOIN orders o ON a.id = o.account_id AND standard_qty > 100
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id;
-- OR
SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100;


-- Q5. Provide the name for each region for every order, as well as
-- the account name and the unit price they paid (total_amt_usd/total)
-- for the order. However, you should only provide the results if
-- the standard order quantity exceeds 100 and the poster order quantity
-- exceeds 50. Your final table should have 3 columns: region name,
-- account name, and unit price. Sort for the smallest unit price first.
-- In order to avoid a division by zero error, adding .01 to the
-- denominator here is helpful (total_amt_usd/(total+0.01).
SELECT a.name account_name, r.name region_name, o.total_amt_usd/(o.total + 0.01) unit_price
FROM accounts a JOIN orders o ON a.id = o.account_id AND standard_qty > 100 AND poster_qty>50
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
ORDER BY unit_price ASC;
-- OR
SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price;


-- Q6. Provide the name for each region for every order, as well as
-- the account name and the unit price they paid (total_amt_usd/total)
-- for the order. However, you should only provide the results if
-- the standard order quantity exceeds 100 and the poster order quantity
-- exceeds 50. Your final table should have 3 columns: region name,
-- account name, and unit price. Sort for the largest unit price first.
-- In order to avoid a division by zero error, adding .01 to the
-- denominator here is helpful (total_amt_usd/(total+0.01).
SELECT a.name account_name, r.name region_name, o.total_amt_usd/(o.total + 0.01) unit_price
FROM accounts a JOIN orders o ON a.id = o.account_id AND standard_qty > 100 AND poster_qty>50
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
ORDER BY unit_price DESC;
-- OR
SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;



-- Q7. What are the different channels used by account id 1001?
-- Your final table should have only 2 columns: account name
-- and the different channels. You can try SELECT DISTINCT
-- to narrow down the results to only the unique values.
SELECT DISTINCT a.name account_name, w.channel
FROM web_events w
JOIN accounts a ON a.id = w.account_id AND w.account_id = 1001;
-- OR
SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';



-- Q8. Find all the orders that occurred in 2015. Your final table
-- should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.
SELECT a.name account_name, o.occurred_at, o.total order_total, o.total_amt_usd
FROM accounts a
RIGHT JOIN orders o ON o.account_id = a.id WHERE o.occurred_at BETWEEN '2015-01-01' AND '2015-12-31';
-- OR
SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;
