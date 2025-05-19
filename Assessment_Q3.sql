SELECT 
    a.id AS plan_id,  -- Unique ID for the account 
    a.owner_id,       -- ID of the users

    -- Determine the type: if the ID exists in the savings table, it's a Savings account; else, Investment
    IF(a.id IN (SELECT id FROM savings_savingsaccount), 'Savings', 'Investment') AS type,

    -- Compare the account creation date and the last withdrawal date
GREATEST(a.created_on,  -- When the account was created
COALESCE((SELECT MAX(w.transaction_date)  -- Get latest withdrawal date by this user
		  FROM withdrawals_withdrawal w 
		  WHERE w.owner_id = a.owner_id 
		  AND (a.id IN (SELECT id FROM savings_savingsaccount) OR w.plan_id = a.id)),'1970-01-01'  -- Default fallback if no withdrawal exists
        )) AS last_transaction_date,

-- Calculate how many days since the last transaction
    DATEDIFF(CURRENT_DATE,
        GREATEST(a.created_on,
		COALESCE((SELECT MAX(w.transaction_date) 
                 FROM withdrawals_withdrawal w 
                 WHERE w.owner_id = a.owner_id 
                 AND (a.id IN (SELECT id FROM savings_savingsaccount) OR w.plan_id = a.id)),'1970-01-01')
	            )
			) AS inactivity_days

-- Getting the union of all accounts: savings and investment accounts with positive balances
FROM ( SELECT id, owner_id, created_on, amount 
       FROM savings_savingsaccount 
	WHERE amount > 0
    UNION ALL
    SELECT id, owner_id, created_on, amount 
    FROM plans_plan 
    WHERE amount > 0
) a

-- Join with users table to filter based on user status
JOIN users_customuser u ON a.owner_id = u.id

-- Only include users who are not null 
WHERE u.is_active = 1
AND (u.is_account_deleted = 0 OR u.is_account_deleted IS NULL)

-- Filter to only include accounts that have been inactive for at least a year
AND GREATEST(a.created_on,
	COALESCE((SELECT MAX(w.transaction_date) 
              FROM withdrawals_withdrawal w 
              WHERE w.owner_id = a.owner_id 
              AND (a.id IN (SELECT id FROM savings_savingsaccount) OR w.plan_id = a.id)),'1970-01-01'
			)) < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY)

-- Sort by the 1000 most inactive
ORDER BY inactivity_days DESC 
LIMIT 1000;