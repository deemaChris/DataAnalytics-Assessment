WITH customer_deposits AS (
    SELECT owner_id AS customer_id,  -- Rename for consistency
	SUM(amount)/100 AS total_deposits,  -- Converting from kobo to main currency
	COUNT(*) AS deposit_count  -- Number of deposit transactions
    FROM savings_savingsaccount
    GROUP BY owner_id
),

-- Calculating the total withdrawals per customer
customer_withdrawals AS (
    SELECT owner_id AS customer_id,  -- Keep same alias as above
	SUM(amount)/100 AS total_withdrawals,  -- Convert from kobo again
	COUNT(*) AS withdrawal_count  -- Number of withdrawals
    FROM withdrawals_withdrawal
    GROUP BY owner_id
),

-- Calculate how long each customer has been with the company
customer_tenure AS (
    SELECT id AS customer_id,  -- Same alias
	CONCAT(first_name, ' ', last_name) AS name,  -- Full name of customer
	TIMESTAMPDIFF(MONTH, created_on, CURRENT_DATE()) AS tenure_months  -- How many months since account creation
    FROM users_customuser
    WHERE is_active = 1  -- Only considering currently active customers
)
-- Combine everything and calculate estimated CLV
SELECT t.customer_id,t.name,t.tenure_months,

-- Total number of deposit + withdrawal transactions
(COALESCE(d.deposit_count, 0) + COALESCE(w.withdrawal_count, 0)) AS total_transactions,

-- Estimated CLV formula:[(Total Deposits - Total Withdrawals) / Tenure in months] * 12  * 0.1% (to get annualized value with a margin)
    ROUND(
        ((COALESCE(d.total_deposits, 0) - COALESCE(w.total_withdrawals, 0)) /
            GREATEST(t.tenure_months, 1)  -- to avoid dividing by zero
        ) * 12 * 0.001,
        2  -- Round to 2 decimal places
    ) AS estimated_clv
   FROM customer_tenure t

-- Join the calculated deposits and withdrawals
LEFT JOIN 
    customer_deposits d ON t.customer_id = d.customer_id
LEFT JOIN 
    customer_withdrawals w ON t.customer_id = w.customer_id

-- Filter out customers with zero months of tenure and show valuable customers first
WHERE 
    t.tenure_months > 0
ORDER BY 
    estimated_clv DESC;