-- Chapter 1: Basic SQL commands on the parch and posey database in Udacity course

SELECT *
FROM orders
LIMIT 10;


SELECT id, account_id, occurred_at
FROM orders
LIMIT 10;


SELECT occurred_at, account_id, channel
FROM web_events
LIMIT 15;


SELECT id, account_id, occurred_at
FROM orders
ORDER BY occurred_at DESC
LIMIT 100;


SELECT *  FROM orders ORDER BY occurred_at DESC LIMIT 10;


SELECT id, occurred_at, total_amt_usd FROM orders ORDER BY occurred_at LIMIT 10;


SELECT id, account_id, total_amt_usd FROM orders ORDER BY total_amt_usd DESC LIMIT 10;


SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC
LIMIT 20;


SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id
LIMIT 20;


SELECT id, account_id, total_amt_usd
FROM orders
WHERE account_id = 4251
ORDER BY total_amt_usd DESC, account_id
LIMIT 20;


SELECT * FROM orders WHERE gloss_amt_usd>=1000 LIMIT 5;

SELECT * FROM orders WHERE total_amt_usd<=500 LIMIT 10;


SELECT name, website, primary_poc
FROM accounts
WHERE name='Exxon Mobil';


-- DERIVED COLUMNS:

SELECT id, (standard_amt_usd/total_amt_usd)*100 AS std_percent, total_amt_usd
FROM orders
LIMIT 10;


--Create a column that divides the standard_amt_usd by the standard_qty to find
-- the unit price for standard paper for each order.
-- Limit the results to the first 10 orders, and include the id and account_id fields.

SELECT id, account_id, (standard_amt_usd/standard_qty) AS std_paper_unit_price
FROM orders
LIMIT 20;


--Write a query that finds the percentage of revenue that comes from poster paper
-- for each order. You will need to use only the columns that end with _usd.
--(Try to do this without using the total column.) Display the id and account_id fields also.

SELECT id, account_id, (poster_amt_usd * 100)/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS poster_revenue_percent
FROM orders
LIMIT 10;


-- LIKE

SELECT * FROM accounts WHERE name LIKE 'C%';

SELECT * FROM accounts WHERE name LIKE '%one%'

SELECT * FROM accounts WHERE name LIKE '%s'


-- IN function allows us to filter data based on several possible values
-- This operator allows you to use an =, but for more than one item
-- of that particular column. We can check one, two or many column values
-- for which we want to pull data, but all within the same query

 SELECT name, primary_poc, sales_rep_id
 FROM accounts
 WHERE name IN ('Target', 'Walmart', 'Nordstrom');


 SELECT * FROM web_events WHERE channel IN ('organic', 'adwords');



 -- By specifying NOT LIKE or NOT IN, we can grab all of the rows that do not meet a particular criteria.

 -- The AND operator is used within a WHERE statement to consider more than one
 -- logical clause at a time. Each time you link a new statement with an AND,
 -- you will need to specify the column you are interested in looking at
 -- Instead of writing : WHERE column >= 6 AND column <= 10
-- we can instead write, equivalently: WHERE column BETWEEN 6 AND 10

SELECT COUNT(*) FROM accounts WHERE name NOT LIKE 'C%' AND name LIKE '%s';

-- When you use the BETWEEN operator in SQL, do the results include the values of your endpoints
SELECT * FROM orders WHERE gloss_qty BETWEEN 24 AND 29;



SELECT * FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;


SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
          AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
          AND primary_poc NOT LIKE '%eana%');
