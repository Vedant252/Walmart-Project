use walmart_db;
select * from walmart;
select count(*) from walmart;


SELECT COUNT(distinct branch)
from walmart;

select max(quantity) from walmart;
select min(quantity) from walmart;

-- Business Problems
-- Q1 What are the different payment methods, and how many transactions and items were sold with each method?
select 
	 payment_method,
     count(*) as no_payments,
     SUM(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Q2 Which category received the highest average rating in each branch?
select *
from
(	select
		branch,
		category,
		avg(rating) as avg_rating,
		rank() over(partition by branch order by avg(rating) desc) as category_rank
	from walmart
	group by branch,category
) as ranked_categories
where category_rank = 1;

-- Q3: What is the busiest day of the week for each branch based on transaction volume?

SELECT *
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS category_rank
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_categories
WHERE category_rank = 1;

-- Q4: How many items were sold through each payment method? List the payment_method and total_quantity
select 
	 payment_method,
     SUM(quantity) as no_qty_sold
from walmart
group by payment_method;

 -- Q5: What are the average, minimum, and maximum ratings for each category in each city?
 -- List the city average_rating, min_rating, max_rating
 
select
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by city, category;

-- Q6: What is the total profit for each category, ranked from highest to lowest?
-- (unit_price * quantity * profit_margin)
-- List category and total_profit, ordered from highest to lowest profit

SELECT
    category,
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category;

-- Q7: What is the most frequently used payment method in each branch?
-- Display Branch and the preferred_payment_method.

WITH cte AS (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS payment_rank
    FROM walmart
    GROUP BY branch, payment_method
)

SELECT *
FROM cte
WHERE payment_rank = 1;

SELECT
    branch,
    CASE
        WHEN HOUR(CAST(time AS TIME)) < 12 THEN 'Morning'
        WHEN HOUR(CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS no_transactions
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, no_transactions DESC;

-- Q9: Which branches experienced the largest decrease in revenue compared to the previous year?
-- Identify 5 branch with highest decrease ratio in
-- revenue compare to last year
-- rdr == last_rev-cr_rev/ls_rev*100
WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2023
    GROUP BY branch
)

SELECT
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,
    ROUND(
        ((ls.revenue - cs.revenue) / ls.revenue) * 100,
        2
    ) AS rev_dec_ratio
FROM revenue_2022 ls
JOIN revenue_2023 cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;