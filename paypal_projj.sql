USE paypal_transactions;

-- Top 5 countries by amount sent
SELECT
    c.country_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_sent
FROM transactions t
JOIN users u
    ON t.sender_id = u.user_id
JOIN countries c
    ON u.country_id = c.country_id
WHERE t.transaction_date >= '2023-10-01'
  AND t.transaction_date < '2024-01-01'
GROUP BY c.country_name
ORDER BY total_sent DESC
LIMIT 5;
-- Top 5 countries by amount received
SELECT
    c.country_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_received
FROM transactions t
JOIN users u
    ON t.recipient_id = u.user_id
JOIN countries c
    ON u.country_id = c.country_id
WHERE t.transaction_date >= '2023-10-01'
  AND t.transaction_date < '2024-01-01'
GROUP BY c.country_name
ORDER BY total_received DESC
LIMIT 5;

-- Find transactions exceeding $10,000 in the year 2023 and include transaction ID, sender ID, recipient ID (if available), transaction amount, and currency used.
 
SELECT 
    transaction_id,
    sender_id,
    recipient_id,
    transaction_amount,
    currency_code
FROM
    transactions
WHERE
    transaction_amount > 10000
        AND transaction_date >= '2023-01-01'
        AND transaction_date < '2024-01-01';    
        
-- To find the top 10 merchants sorted by total transaction amount received between November 2023 and April 2024
SELECT
    m.merchant_id,
    m.business_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_received,
    ROUND(AVG(t.transaction_amount), 2) AS average_transaction
FROM transactions t
JOIN merchants m
    ON t.recipient_id = m.merchant_id
WHERE t.transaction_date >= '2023-11-01'
  AND t.transaction_date < '2024-05-01'
GROUP BY
    m.merchant_id,
    m.business_name
ORDER BY total_received DESC
LIMIT 10;
-- Calculate the total amount converted from each source currency to the top 3 most popular destination currencies. from 22 May 2023 to 22 May 2024.
SELECT
    currency_code,
    SUM(transaction_amount) AS total_converted
FROM transactions
WHERE transaction_date >= '2023-05-22'
  AND transaction_date < '2024-05-23'
GROUP BY currency_code
ORDER BY total_converted DESC
LIMIT 3;

-- Categorize transactions as 'High Value' (above $10,000) or 'Regular' (less than or equal to $10,000) and 
-- calculate the total amount for each category for the year 2023.
SELECT 
    CASE
        WHEN transaction_amount > 10000 THEN 'High Value'
        ELSE 'Regular'
    END AS transaction_category,
    SUM(transaction_amount) AS total_amount
FROM
    transactions
WHERE
    transaction_date >= '2023-01-01'
        AND transaction_date < '2024-01-01'
GROUP BY transaction_category;

-- the finance team needs to identify the nature of transactions conducted by the company.for the first quarter of 2024 (January to March).
SELECT
    CASE
        WHEN sender.country_id = recipient.country_id
            THEN 'Domestic'
        ELSE 'International'
    END AS transaction_type,
    COUNT(*) AS transaction_count
FROM transactions t
JOIN users sender
    ON t.sender_id = sender.user_id
JOIN users recipient
    ON t.recipient_id = recipient.user_id
WHERE t.transaction_date >= '2024-01-01'
  AND t.transaction_date < '2024-04-01'
GROUP BY transaction_type;


-- calculate the average transaction amount for each user during the specified six-month period, then keep only users whose average is greater than $5,000.
SELECT 
    u.user_id,
    u.email,
    ROUND(AVG(t.transaction_amount), 2) AS avg_amount
FROM transactions t
JOIN users u
    ON t.sender_id = u.user_id
WHERE t.transaction_date >= '2023-11-01'
  AND t.transaction_date < '2024-05-01'
GROUP BY u.user_id, u.email
HAVING AVG(t.transaction_amount) > 5000
ORDER BY u.user_id ASC;


-- need to group the transactions by year and month and calculate the total transaction amount for each month in 2023.
SELECT
    YEAR(transaction_date) AS transaction_year,
    MONTH(transaction_date) AS transaction_month,
    SUM(transaction_amount) AS total_amount
FROM transactions
WHERE transaction_date >= '2023-01-01'
  AND transaction_date < '2024-01-01'
GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date)
ORDER BY
    transaction_year ASC,
    transaction_month ASC;
    
    
-- find the user with the highest total transaction amount between May 22, 2023 and May 22, 2024.
 SELECT
    u.user_id,
    u.email,u.name,
    ROUND(SUM(t.transaction_amount), 2) AS total_amount
FROM transactions t
JOIN users u
    ON t.sender_id = u.user_id
WHERE t.transaction_date >= '2023-05-22'
  AND t.transaction_date < '2024-05-23'
GROUP BY
    u.user_id,
     u.email, u.name
ORDER BY total_amount DESC
LIMIT 1;   


-- find which currency had the highest total transaction amount during the past year, assuming today is 22 May 2024.

SELECT
    currency_code,
    ROUND(SUM(transaction_amount), 2) AS total_amount
FROM transactions
WHERE transaction_date >= '2023-05-22'
  AND transaction_date < '2024-05-23'
GROUP BY currency_code
ORDER BY total_amount DESC
LIMIT 1;

-- The sales team wants to identify top-performing merchants. Which merchant should be considered as the most successful in terms of 
-- total transaction amount received between November 2023 and April 2024?

SELECT
    m.merchant_id,
    m.business_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_received
FROM transactions t
JOIN merchants m
    ON t.recipient_id = m.merchant_id
WHERE t.transaction_date >= '2023-11-01'
  AND t.transaction_date < '2024-05-01'
GROUP BY
    m.merchant_id,
    m.business_name
ORDER BY total_received DESC
LIMIT 1;


SELECT
    CASE
        WHEN t.transaction_amount > 10000
             AND sender.country_id <> recipient.country_id
            THEN 'High Value International'

        WHEN t.transaction_amount > 10000
             AND sender.country_id = recipient.country_id
            THEN 'High Value Domestic'

        WHEN t.transaction_amount <= 10000
             AND sender.country_id <> recipient.country_id
            THEN 'Regular International'

        ELSE 'Regular Domestic'
    END AS transaction_category,
    COUNT(*) AS transaction_count
FROM transactions t
JOIN users sender
    ON t.sender_id = sender.user_id
JOIN users recipient
    ON t.recipient_id = recipient.user_id
WHERE t.transaction_date >= '2023-01-01'
  AND t.transaction_date < '2024-01-01'
GROUP BY transaction_category
ORDER BY transaction_category desc;


SELECT 
    YEAR(t.transaction_date) AS transaction_year,
    MONTH(t.transaction_date) AS transaction_month,
    CASE
        WHEN t.transaction_amount > 10000 THEN 'High Value'
        ELSE 'Regular'
    END AS value_category,
    CASE
        WHEN sender.country_id <> recipient.country_id THEN 'International'
        ELSE 'Domestic'
    END AS location_category,
    ROUND(SUM(t.transaction_amount), 2) AS total_amount,
    ROUND(AVG(t.transaction_amount), 2) AS average_amount
FROM
    transactions t
        JOIN
    users sender ON t.sender_id = sender.user_id
        JOIN
    users recipient ON t.recipient_id = recipient.user_id
WHERE
    t.transaction_date >= '2023-01-01'
        AND t.transaction_date < '2024-01-01'
GROUP BY YEAR(t.transaction_date) , MONTH(t.transaction_date) , value_category , location_category
ORDER BY transaction_year ASC , transaction_month ASC , value_category ASC , location_category ASC;