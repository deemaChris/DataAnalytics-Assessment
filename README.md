Each SQL file contains one query that is properly formatted, well-indented, and annotated with helpful comments.

---

##  Per-Question Explanations

---
###  Assessment_Q1.sql — **Active Users with Both Savings and Investment Accounts**  
Users with at least one investment account and one savings account are identified by this query.

- Both have positive balances.
- To make sure that both account types are present, it sums data by user, joins the users table with the corresponding account tables, and applies filters using the HAVING clause.
- Additionally, it determines a total_deposits value to categorize people according to their level of interaction.

---
###  Assessment_Q2.sql — **Customer Summary Report**  
This search provides a consolidated view of a client's:

- The number of transactions (deposits plus withdrawals), the tenure (in months),
- CLV was estimated using the same reasoning as Q1.
- It applies a straightforward formula for customer value and merges the previously calculated customer data (tenure, withdrawals, and deposits).

---
###  Assessment_Q3.sql — **Inactive Accounts Over One Year**  
This search identifies accounts that haven't had any deposits or withdrawals for more than a year:

- Uses UNION ALL to combine investment and savings accounts.
- The most recent transaction date (if any) is calculated, reverting to the account's original creation date.
- Accounts where the most recent activity is more than a year old are filtered.
- Retrieves the pertinent activity date using GREATEST() and COALESCE().

---
###  Assessment_Q4.sql — **Customer Lifetime Value (CLV)**  
This query uses the following reasoning to determine the predicted CLV for each active customer:

- The total amount of money deposited and taken out of savings accounts.
- Determine tenure in months by using the date the user's account was created.
- Calculate the average monthly net contribution and use a profit margin multiplier to project it over a year to estimate CLV.
- For improved readability and modular construction, I used CTEs.

---

##  Challenges & Resolutions
- Managing Inactivity Logic (Q3): Careful usage of subqueries and backup logic was necessary to ensure the accurate "last activity" date across two sources (accounts and withdrawals). To make this strong, I combined GREATEST() and COALESCE(). 
- CLV Calculation (Q1 & Q4): Using GREATEST(tenure, 1) to avoid division by zero was necessary to estimate financial value over time. Data Normalization: All monetary fields were translated to base currency by dividing by 100 because quantities were stored in kobo.

---

## Ownership & Ethics
All of the art is original to me.

- No solutions from other sources were duplicated, distributed, or modified.
- As directed, the contribution just contains this README.md and SQL files.

---

Thank you for reviewing my submission.
