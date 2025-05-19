SELECT 
    u.id AS owner_id,  --  Get the unique ID of each user
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Create a full name by combining the firstname and lastname

    -- Count how many savings accounts the user has to get unique IDs
    COUNT(DISTINCT s.id) AS savings_count,

    -- Count how many unique investment plans the user has
    COUNT(DISTINCT p.id) AS investment_count,

    -- adding the amounts from both savings and investments, NULLs = 0
    -- (COALESCE prevents NULL + NULL = NULL, which would scatter total_deposits)
    COALESCE(SUM(s.amount), 0) + COALESCE(SUM(p.amount), 0) AS total_deposits
FROM 
    users_customuser u  -- list of users

-- LEFT JOIN ensures users are not excluded if they don’t have savings 
LEFT JOIN 
    savings_savingsaccount s ON s.owner_id = u.id AND s.amount > 0  

-- Same for investment plans - only with amount greater than 0
LEFT JOIN 
    plans_plan p ON p.owner_id = u.id AND p.amount > 0  

-- Grouping by user 
GROUP BY 
    u.id, u.first_name, u.last_name

-- Filtering down to users who have BOTH savings and investment accounts
HAVING 
    COUNT(DISTINCT s.id) > 0 AND COUNT(DISTINCT p.id) > 0
ORDER BY 
    total_deposits DESC;