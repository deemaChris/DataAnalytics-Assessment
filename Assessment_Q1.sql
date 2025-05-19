-- Selecting fields for each user
SELECT 
    u.id AS owner_id,  -- Get the user's ID and label it as 'owner_id'
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Combine first and last names into a full name
    COUNT(DISTINCT s.id) AS savings_count,  -- Count the number of unique savings accounts per user
    COUNT(DISTINCT p.id) AS investment_count,  -- Count the number of unique investment plans per user
    COALESCE(SUM(s.amount), 0) + COALESCE(SUM(p.amount), 0) AS total_deposits  -- Add up all deposits from savings and plans, inputting 0 if null
FROM 
    users_customuser u  

-- Lets left join with savings accounts, i'm joining amunts greater than 0
LEFT JOIN 
    savings_savingsaccount s ON s.owner_id = u.id AND s.amount > 0  

-- Lets left join the tble we created with investment plans, here too, the amount is greater than 0
LEFT JOIN 
    plans_plan p ON p.owner_id = u.id AND p.amount > 0  

-- Group by user so we can get each persons data 
GROUP BY 
    u.id, u.first_name, u.last_name

-- We want toinclude users who have at least one savings AND one investment account
HAVING 
    COUNT(DISTINCT s.id) > 0 AND COUNT(DISTINCT p.id) > 0

-- Sort the results by total deposits in descending order
ORDER BY 
    total_deposits DESC;