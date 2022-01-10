-- LEFT & RIGHT

-- LEFT pulls a specified number of characters for each row in a specified
-- column starting at the beginning (or from the left).

-- RIGHT pulls a specified number of characters for each row in a specified
-- column starting at the end (or from the right).

-- LENGTH provides the number of characters for each row of a specified column.
-- To get the length of each phone number: LENGTH(phone_number).

-- NOTE: Innermost functions will be evaluated first


-- Q1. In the accounts table, there is a column holding the website for each
-- company. The last three digits specify what type of web address they are
-- using. Pull these extensions and provide how many of each website type exist
-- in the accounts table.
SELECT RIGHT(website, 3), COUNT(id)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;


-- Q2. There is much debate about how much the name (or even the first letter
-- of a company name) matters. Use the accounts table to pull the first letter
-- of each company name to see the distribution of company names that begin
-- with each letter (or number).
SELECT LEFT(UPPER(name), 1), COUNT(id)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;


-- Q3. Use the accounts table and a CASE statement to create two groups: one
-- group of company names that start with a number and a second group of those
-- company names that start with a letter. What proportion of company names
-- start with a letter?
SELECT CASE WHEN LEFT(name, 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'DIGIT'
            ELSE 'LETTER' END first_char_of_name
       , COUNT(id)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;


-- Consider vowels as a, e, i, o, and u. What proportion of company names start
--  with a vowel, and what percent start with anything else?
SELECT CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U') THEN 'vowel'
            ELSE 'other' END first_char_of_name
       , COUNT(id)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;




-- ============================================================================
-- ============================================================================

-- POSITION, STRPOS, SUBSTR

-- POSITION(',' IN city_state)
-- STRPOS(city_state, ',')
-- The above two funtions are case senstitive
-- if you want to pull an index regardless of the case of a letter, you might
-- want to use LOWER or UPPER to make all of the characters lower or uppercase.

-- Q1. Use the accounts table to create first and last name columns that
-- hold the first and last names for the primary_poc.
SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) first_name,
       RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
FROM accounts;



-- Q2. Now see if you can do the same thing for every rep name in the sales_reps
--  table. Again provide first and last name columns.
SELECT LEFT(name, POSITION(' ' IN name)-1) first_name,
       RIGHT(name, LENGTH(name)-POSITION(' ' IN name)) last_name
FROM sales_reps;





-- ============================================================================
-- ============================================================================

-- CONCAT, piping ||

-- CONCAT(first_name, ' ', last_name)
-- same as - first_name || ' ' || last_name

-- Q1. Each company in the accounts table wants to create an email address for
-- each primary_poc. The email address should be the first name of the
-- primary_poc . last name primary_poc @ company name .com.
SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)
      || '.' ||
      RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc))
      || '@' || name || '.com' primary_poc_email
FROM accounts;
-- or
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;



-- Q2. You may have noticed that in the previous solution some of the company
-- names include spaces, which will certainly not work in an email address.
-- See if you can create an email address that will work by removing all of the
-- spaces in the account name, but otherwise your solution should be just as
-- in question 1.
SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)
       || '.' ||
       RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc))
       || '@' || REPLACE(name, ' ', '') || '.com' primary_poc_email
FROM accounts;
-- or
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;


-- Q3. We would also like to create an initial password, which they will change
-- after their first log in. The first password will be the first letter of the
--  primary_poc's first name (lowercase), then the last letter of their first
-- name (lowercase), the first letter of their last name (lowercase), the last
-- letter of their last name (lowercase), the number of letters in their first
-- name, the number of letters in their last name, and then the name of the
-- company they are working with, all capitalized with no spaces.
SELECT CONCAT(LOWER(LEFT(LOWER(primary_poc), 1)), '',
              LOWER(RIGHT(LOWER(LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)), 1)), '',
              LOWER(LEFT(RIGHT(name, LENGTH(name)-POSITION(' ' IN name)),1)), '',
              LOWER(RIGHT(RIGHT(name, LENGTH(name)-POSITION(' ' IN name)),1)), '',
              LENGTH(LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)), '',
              LENGTH(RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc))), '',
              UPPER(name)) as pwd
FROM accounts;
-- or
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;





-- ============================================================================
-- ============================================================================

-- CAST, ::

-- CAST allows us to change columns from one data type to another
-- CAST(date_column AS DATE)

-- Ex: Converting month names to numbers and creating date
SELECT * , DATE_PART('month', TO_DATE(month, 'month')) AS month_num, -- here changed a month name into the number associated with that particular month.
      year || '-' || DATE_PART('month', TO_DATE(month, 'month')) || '-' || day AS date_form
      CAST(year || '-' || DATE_PART('month', TO_DATE(month, 'month')) || '-' || day AS DATE) sql_date
FROM table

-- or, instead of CAST(), we can use the following
(year || '-' || DATE_PART('month', TO_DATE(month, 'month')) || '-' || day)::DATE


-- The CAST function is most useful in turning Strings into numbers or dates

-- LEFT, RIGHT, TRIM or SUBSTRING automatically cast data to a String datatype
-- TRIM can be used to remove characters from the beginning and end of a string.
  -- This can remove unwanted spaces at the beginning or end of a row that
  -- often happen with data being moved from Excel or other storage systems.




  -- ============================================================================
  -- ============================================================================

  -- COALESCE

  -- COALESCE funtion returns the first non null value passed for each row

  -- To replace NULLs with some value:
  SELECT * , COALESCE(primary_poc, 'no POC') primary_poc_modified
  FROM accounts
  WHERE primary_poc IS NULL


  SELECT COUNT(primary_poc) regular_count, COUNT(COALESCE(primary_poc, 'no POC')) modified_count
  FROM accounts


-- Q1.  TO find row with NULL value
SELECT *
FROM accounts a
LEFT JOIN orders o ON a.id = o.account_id
WHERE o.total IS NULL;


-- Q2
SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


-- Q3
SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id
       , COALESCE(o.account_id, a.id) account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total, o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- Q4.
 SELECT a.*, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty,
        COALESCE(o.gloss_qty, 0), COALESCE(o.poster_qty, 0) poster_qty,
        COALESCE(o.total, 0) total,
        COALESCE(o.standard_amt_usd, 0) standard_amt_usd,
        COALESCE(o.gloss_amt_usd,0) gloss_amt_usd,
        COALESCE(o.poster_amt_usd, 0) poster_amt_usd,
        COALESCE (o.total_amt_usd, 0) total_amt_usd
FROM accounts a
LEFT JOIN orders o ON a.id = o.account_id
WHERE o.total IS NULL;



-- Q5.
SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long,
       a.primary_poc, a.sales_rep_id,
       COALESCE(o.account_id, a.id) account_id, o.occurred_at,
       COALESCE(o.standard_qty, 0) standard_qty,
       COALESCE(o.gloss_qty,0) gloss_qty,
       COALESCE(o.poster_qty,0) poster_qty,
       COALESCE(o.total,0) total,
       COALESCE(o.standard_amt_usd,0) standard_amt_usd, 
       COALESCE(o.gloss_amt_usd,0) gloss_amt_usd,
       COALESCE(o.poster_amt_usd,0) poster_amt_usd,
       COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;
