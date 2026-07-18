-- Q1. Overall attrition rate

SELECT
	COUNT(*) AS total_employees,
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
	ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM attrition;

-- Q2. Headcount by department

SELECT
	department,
	COUNT(*) AS head_count
FROM demographics
GROUP BY department
ORDER BY head_count DESC;

-- Q3. Average monthly income overall and by job role

SELECT
	d.jobrole,
	ROUND(AVG(c.monthlyincome),2) AS average_income,
	COUNT(*) AS head_count
FROM demographics d
JOIN compensation c ON d.employeeid = c.employeeid
GROUP BY d.jobrole
ORDER BY average_income DESC;

-- Q4. Average age and tenure of employees who left vs stayed

SELECT
	a.attrition,
	ROUND(AVG(d.age),1) AS avg_age,
	ROUND(AVG(e.yearsatcompany),1) AS avg_years_at_company
FROM demographics d
JOIN employment e ON d.employeeid = e.employeeid
JOIN attrition a ON d.employeeid = a.employeeid	
GROUP BY a.attrition;


-- Q5. Attrition count by marital status

SELECT
	d.maritalstatus,
	COUNT(*) AS head_count,
	SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count
FROM demographics d
JOIN attrition a ON d.employeeid = a.employeeid
GROUP BY d.maritalstatus;


-- Q6. Attrition rate by department (rate, not just raw count)

SELECT
	d.department,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
FROM demographics d
JOIN attrition a ON d.employeeid = a.employeeid
GROUP BY d.department
ORDER BY attrition_rate_pct DESC;

-- Q7. Attrition rate by OverTime status

SELECT
	e.overtime,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
FROM employment e
JOIN attrition a ON e.employeeid = a.employeeid
GROUP BY e.overtime
ORDER BY attrition_rate_pct DESC;

-- Q8. Attrition rate by income band

SELECT
	CASE
		WHEN c.monthlyincome < 3000 THEN '<3000'
		WHEN c.monthlyincome < 6000 THEN '3000-5999'
		WHEN c.monthlyincome < 10000 THEN '6000-9999'
		ELSE '10000+'
	END AS income_band,
	COUNT(*) AS total_employee,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
FROM compensation c
JOIN attrition a ON c.employeeid = a.employeeid
GROUP BY income_band
ORDER BY MIN(c.monthlyincome);

-- Q9. Attrition rate by tenure bucket

SELECT
	CASE 
		WHEN e.yearsatcompany <= 2 THEN '0-2 yrs'
		WHEN e.yearsatcompany <= 5 THEN '3-5 yrs'
		WHEN e.yearsatcompany <= 6 THEN '6-10 yrs'
		ELSE '10+ yrs'
	END AS tenure_bucket,
	COUNT(*) AS total_employees,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employment e
JOIN attrition a ON e.employeeid = a.employeeid
GROUP BY tenure_bucket
ORDER BY MIN(e.yearsatcompany);

-- Q10. Average satisfaction scores: leavers vs stayers

SELECT
	a.attrition,
	ROUND(AVG(s.jobsatisfaction),2) AS avg_job_satisfaction,
	ROUND(AVG(s.environmentsatisfaction),2) AS avg_environment_satisfaction,
	ROUND(AVG(s.worklifebalance),2) AS avg_worklife_balance,
	ROUND(AVG(s.jobinvolvement),2) AS avg_job_involvement
FROM satisfaction s
JOIN attrition a ON s.employeeid = a.employeeid
GROUP BY a.attrition;

-- Q11. Attrition rate by department AND overtime combined

SELECT
	d.department,
	e.overtime,
	COUNT(*) AS total_employees,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
FROM demographics d
JOIN employment e ON d.employeeid = e.employeeid
JOIN attrition a ON d.employeeid = a.employeeid
GROUP BY d.department, e.overtime
ORDER BY d.department, attrition_rate_pct DESC;

-- Q12. Salary hike vs attrition

SELECT
	CASE 
		WHEN c.percentsalaryhike < 15 THEN 'Low hike (<15%)'
		WHEN c.percentsalaryhike < 20 THEN 'Medium hike (15-19%)'
		ELSE 'High hike (20%+)'
	END AS hike_band,
	COUNT(*) AS total_employees,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
FROM compensation c
JOIN attrition a ON c.employeeid = a.employeeid
GROUP BY hike_band;

-- Q13. Rank job roles by attrition rate (window function)

SELECT
	jobrole,
	attrition_rate_pct,
	RANK() OVER (ORDER BY attrition_rate_pct) AS attrition_rank
FROM (
	SELECT
		d.jobrole,
		ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
	FROM demographics d 
	JOIN attrition a ON d.employeeid = a.employeeid
	GROUP BY d.jobrole
);

-- Q14. Employees earning below their own job role's average income

SELECT
	d.employeeid,
	d.jobrole,
	c.monthlyincome,
	ROUND(AVG(c.monthlyincome) OVER (PARTITION BY d.jobrole),0) AS avg_income_for_role,
	a.attrition
FROM demographics d
JOIN compensation c ON d.employeeid = c.employeeid
JOIN attrition a ON d.employeeid = a.employeeid
WHERE c.monthlyincome < (
	SELECT AVG(c2.monthlyincome)
	FROM demographics d2
	JOIN compensation c2 ON d2.employeeid = c2.employeeid
	WHERE d2.jobrole = d.jobrole
)
ORDER BY d.jobrole, c.monthlyincome;

-- Q15. Income quartiles (NTILE) vs attrition rate

WITH income_quartiles AS (
	SELECT
		employeeid,
		monthlyincome,
		NTILE(4) OVER (ORDER BY monthlyincome) AS income_quartile
	FROM compensation
)
SELECT
	iq.income_quartile,
	COUNT(*) AS total_employees,
	ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
FROM income_quartiles iq
JOIN attrition a ON iq.employeeid = a.employeeid
GROUP BY iq.income_quartile
ORDER BY iq.income_quartile;

-- Q16. Multi-factor "high flight-risk" flag

SELECT
	d.employeeid,
	d.department,
	d.jobrole,
	e.overtime,
	e.yearssincelastpromotion,
	s.jobsatisfaction,
	s.worklifebalance,
	a.attrition
FROM demographics d
JOIN employment e ON d.employeeid = e.employeeid
JOIN satisfaction s ON d.employeeid = s.employeeid
JOIN attrition a ON d.employeeid = a.employeeid
WHERE e.overtime = 'Yes'
	AND s.jobsatisfaction <= 2
	AND s.worklifebalance <= 2
	AND e.yearssincelastpromotion >= 3
ORDER BY d.department, d.jobrole;

-- Q17. One combined summary table: attrition rate by every major factor (CTE + UNION ALL)

WITH by_overtime AS (
	SELECT 'OverTime:' || e.overtime AS factor,
			ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct,
			COUNT(*) AS n
	FROM employment e JOIN attrition a ON e.employeeid = a.employeeid
	GROUP BY e.overtime
),
by_marital AS (
	SELECT 'Marital:' || d.maritalstatus AS factor,
			ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct,
			COUNT(*) AS n
	FROM demographics d JOIN attrition a ON d.employeeid = a.employeeid
	GROUP BY d.maritalstatus
),
by_department AS (
	SELECT 'Department:' || d.department AS factor,
			ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct,
			COUNT(*) AS n
	FROM demographics d JOIN attrition a ON d.employeeid = a.employeeid
	GROUP BY d.department
)
SELECT * FROM by_overtime
UNION ALL
SELECT * FROM by_marital
UNION ALL
SELECT * FROM by_department
ORDER BY attrition_rate_pct DESC;

-- Q18. Year-over-tenure "risk curve" using LAG

WITH tenure_attrition AS (
	SELECT
		e.yearsatcompany,
		COUNT(*) AS total_employees,
		ROUND(100.0 * SUM(CASE WHEN a.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate_pct
	FROM employment e
	JOIN attrition a ON e.employeeid = a.employeeid
	GROUP BY e.yearsatcompany
)
SELECT
	yearsatcompany,
	total_employees,
	attrition_rate_pct,
	attrition_rate_pct - LAG(attrition_rate_pct) OVER (ORDER BY yearsatcompany) AS change_vs_prev_year
FROM tenure_attrition
ORDER BY yearsatcompany;