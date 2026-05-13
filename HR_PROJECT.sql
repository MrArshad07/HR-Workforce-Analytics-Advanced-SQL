CREATE SCHEMA IF NOT EXISTS hr_project;
SET search_path TO hr_project;

DROP TABLE IF EXISTS attendance_monthly, performance_reviews, salary_history, employees, job_roles, departments CASCADE;

CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  department_name VARCHAR(50),
  region VARCHAR(20)
);
CREATE TABLE job_roles (
  job_id INT PRIMARY KEY,
  job_title VARCHAR(80),
  job_level INT,
  min_salary INT,
  max_salary INT
);
CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  employee_name VARCHAR(100),
  gender VARCHAR(10),
  birth_date DATE,
  hire_date DATE,
  exit_date DATE,
  employment_status VARCHAR(20),
  department_id INT REFERENCES departments(department_id),
  job_id INT REFERENCES job_roles(job_id),
  manager_id INT,
  city VARCHAR(50),
  employment_type VARCHAR(20)
);
CREATE TABLE salary_history (
  salary_id INT PRIMARY KEY,
  employee_id INT REFERENCES employees(employee_id),
  effective_date DATE,
  base_salary INT,
  bonus_percent NUMERIC(5,2)
);
CREATE TABLE performance_reviews (
  review_id INT PRIMARY KEY,
  employee_id INT REFERENCES employees(employee_id),
  review_date DATE,
  review_year INT,
  quarter VARCHAR(2),
  performance_score NUMERIC(4,2),
  productivity_score NUMERIC(4,2),
  quality_score NUMERIC(4,2),
  teamwork_score NUMERIC(4,2),
  manager_rating NUMERIC(4,2),
  promotion_flag VARCHAR(3),
  training_hours INT
);
CREATE TABLE attendance_monthly (
  attendance_id INT PRIMARY KEY,
  employee_id INT REFERENCES employees(employee_id),
  month_start DATE,
  working_days INT,
  present_days INT,
  late_days INT,
  leave_days INT,
  overtime_hours NUMERIC(5,1)
);

/* 1. Find Top 10 Highest Paid Employees

Show:

employee name
department
current salary
rank based on salary
*/
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    s.base_salary AS current_salary,
    RANK() OVER (
        ORDER BY s.base_salary DESC
    ) AS salary_rank
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN salary_history s
    ON e.employee_id = s.employee_id
ORDER BY current_salary DESC
LIMIT 10;

/* 2. Department Wise Average Salary

Find:

averag
highest salary
lowest salary
for each department. */

SELECT
    d.department_name,
    ROUND(AVG(s.base_salary),2) AS avg_salary,
    MAX(s.base_salary) AS max_salary,
    MIN(s.base_salary) AS min_salary

FROM employees e

JOIN departments d
    ON e.department_id = d.department_id

JOIN salary_history s
    ON e.employee_id = s.employee_id

GROUP BY d.department_name

ORDER BY avg_salary DESC;

/*3. Employees With Salary Above Department Average */

WITH dept_avg_salary AS (

    SELECT
        e.department_id,
        AVG(s.base_salary) AS avg_salary

    FROM employees e

    JOIN salary_history s
        ON e.employee_id = s.employee_id

    GROUP BY e.department_id
)

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    s.base_salary,
    da.avg_salary

FROM employees e

JOIN departments d
    ON e.department_id = d.department_id

JOIN salary_history s
    ON e.employee_id = s.employee_id

JOIN dept_avg_salary da
    ON e.department_id = da.department_id

WHERE s.base_salary > da.avg_salary

ORDER BY s.base_salary DESC;


/*
4. Monthly Attendance Percentage

Calculate attendance percentage for every employee each month.
*/

SELECT
    e.employee_id,
    e.employee_name,

    DATE_TRUNC('month', a.month_start) AS attendance_month,

    SUM(a.present_days) AS total_present_days,
    SUM(a.working_days) AS total_working_days,

    ROUND(
        (SUM(a.present_days)::NUMERIC
        / SUM(a.working_days)) * 100,
        2
    ) AS attendance_percentage

FROM employees e

JOIN attendance_monthly a
    ON e.employee_id = a.employee_id

GROUP BY
    e.employee_id,
    e.employee_name,
    DATE_TRUNC('month', a.month_start)

ORDER BY
    attendance_month,
    e.employee_id;

/*
 5. Top 5 Employees By Performance Score

Find highest performance employees in each department.
*/

WITH ranked_employees AS (

    SELECT
        e.employee_id,
        e.employee_name,
        p.performance_score,
        d.department_name,

        DENSE_RANK() OVER (
            PARTITION BY d.department_name
            ORDER BY p.performance_score DESC
        ) AS top_employee_performance

    FROM employees e

    JOIN performance_reviews p
        ON e.employee_id = p.employee_id

    JOIN departments d
        ON e.department_id = d.department_id
)

SELECT *
FROM ranked_employees
WHERE top_employee_performance <= 5
ORDER BY department_name, top_employee_performance;

/* 6. Find Employees Who Never Took Leave

Identify employees with 100% attendance. */

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    SUM(a.working_days) AS total_working_days,
    SUM(a.present_days) AS total_present_days,
    SUM(a.leave_days) AS total_leave_days
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN attendance_monthly a
    ON e.employee_id = a.employee_id
GROUP BY
    e.employee_id,
    e.employee_name,
    d.department_name
HAVING
    SUM(a.leave_days) = 0
    AND SUM(a.present_days) = SUM(a.working_days)
ORDER BY e.employee_id;

/*
7. Salary Growth Analysis

Find employees whose salary increased by more than 20%.
*/

WITH salary_growth AS (

    SELECT
        employee_id,
        effective_date,
        base_salary,

        LAG(base_salary) OVER (
            PARTITION BY employee_id
            ORDER BY effective_date
        ) AS previous_salary

    FROM salary_history
)

SELECT
    e.employee_id,
    e.employee_name,
    sg.previous_salary,
    sg.base_salary AS current_salary,

    ROUND(
        ((sg.base_salary - sg.previous_salary)::NUMERIC
        / sg.previous_salary) * 100,
        2
    ) AS salary_growth_percentage

FROM salary_growth sg

JOIN employees e
    ON sg.employee_id = e.employee_id

WHERE
    previous_salary IS NOT NULL
    AND ((sg.base_salary - sg.previous_salary)::NUMERIC
    / sg.previous_salary) * 100 > 20

ORDER BY salary_growth_percentage DESC;


/*
8. Most Common Job Role In Company

Find:
- role with highest employee count
- percentage contribution
*/

SELECT
    j.job_title,
    COUNT(e.employee_id) AS employee_count,
    ROUND(
        COUNT(e.employee_id) * 100.0
        / SUM(COUNT(e.employee_id)) OVER (),
        2
    ) AS percentage_contribution
FROM job_roles j
JOIN employees e
    ON j.job_id = e.job_id
GROUP BY j.job_title
ORDER BY employee_count DESC
LIMIT 1;

/*
9. Employee Experience Analysis
*/

SELECT
    employee_id,
    employee_name,
    hire_date,

    DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS total_experience_years,

    CASE
        WHEN DATE_PART('year', AGE(CURRENT_DATE, hire_date)) < 3
            THEN 'Junior'

        WHEN DATE_PART('year', AGE(CURRENT_DATE, hire_date)) BETWEEN 3 AND 7
            THEN 'Mid-Level'

        ELSE 'Senior'
    END AS employee_category

FROM employees
ORDER BY total_experience_years DESC;


/*
10. Detect Salary Outliers
*/

WITH salary_analysis AS (
    SELECT
        e.employee_id,
        e.employee_name,
        d.department_name,
        s.base_salary,

        AVG(s.base_salary) OVER (
            PARTITION BY d.department_name
        ) AS department_avg_salary

    FROM employees e

    JOIN departments d
        ON e.department_id = d.department_id

    JOIN salary_history s
        ON e.employee_id = s.employee_id
)

SELECT
    employee_id,
    employee_name,
    department_name,
    base_salary,
    ROUND(department_avg_salary, 2) AS department_avg_salary
FROM salary_analysis
WHERE base_salary > department_avg_salary * 1.5
ORDER BY base_salary DESC;

/*
11. Attrition Risk Employees

Condition:
- low performance
- low attendance
- no salary hike in last 2 years
*/

WITH latest_performance AS (
    SELECT
        employee_id,
        performance_score,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn
    FROM performance_reviews
),

attendance AS (
    SELECT
        employee_id,
        ROUND(
            SUM(present_days)::NUMERIC / SUM(working_days) * 100,
            2
        ) AS attendance_percentage
    FROM attendance_monthly
    GROUP BY employee_id
),

last_hike AS (
    SELECT
        employee_id,
        MAX(effective_date) AS last_salary_update
    FROM salary_history
    GROUP BY employee_id
)

SELECT
    e.employee_id,
    e.employee_name,
    lp.performance_score,
    a.attendance_percentage,
    lh.last_salary_update,
	d.department_name,

    'High Attrition Risk' AS risk_status

FROM employees e
JOIN latest_performance lp
    ON e.employee_id = lp.employee_id
JOIN attendance a
    ON e.employee_id = a.employee_id
JOIN last_hike lh
    ON e.employee_id = lh.employee_id
JOIN departments d
    ON e.department_id=d.department_id

WHERE lp.rn = 1
  AND lp.performance_score < 3
  AND a.attendance_percentage < 80
  AND lh.last_salary_update < CURRENT_DATE - INTERVAL '2 years'

ORDER BY
    lp.performance_score,
    a.attendance_percentage;

	 
/*
12. Consecutive Absence Detection

Find employees absent for 3 or more consecutive days.
*/

WITH absence_data AS (

    SELECT
        employee_id,
        month_start,
        leave_days,

        LAG(month_start) OVER (
            PARTITION BY employee_id
            ORDER BY month_start
        ) AS previous_absence_date

    FROM attendance_monthly

    WHERE leave_days > 0
)

SELECT
    e.employee_id,
    e.employee_name,
    a.month_start AS absence_date,
    a.previous_absence_date,

    (a.month_start - a.previous_absence_date) AS day_difference

FROM absence_data a

JOIN employees e
    ON a.employee_id = e.employee_id

WHERE
    (a.month_start - a.previous_absence_date) <= 3

ORDER BY
    e.employee_id,
    a.month_start;


/*
13. Best Performing Department

Find department with:
- highest average performance
- lowest absenteeism
*/

SELECT
    d.department_name,

    ROUND(AVG(p.performance_score), 2) AS avg_performance_score,

    ROUND(
        (
            SUM(a.leave_days)::NUMERIC
            / SUM(a.working_days)
        ) * 100,
        2
    ) AS absenteeism_percentage

FROM departments d

JOIN employees e
    ON d.department_id = e.department_id

JOIN performance_reviews p
    ON e.employee_id = p.employee_id

JOIN attendance_monthly a
    ON e.employee_id = a.employee_id

GROUP BY d.department_name

ORDER BY
    avg_performance_score DESC,
    absenteeism_percentage ASC

LIMIT 1;

/*
14. Promotion Eligibility Dashboard

Employees eligible for promotion:
- performance > 4
- attendance > 90%
- experience > 3 years
*/

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,

    ROUND(AVG(p.performance_score), 2) AS avg_performance_score,

    ROUND(
        (SUM(a.present_days)::NUMERIC
        / SUM(a.working_days)) * 100,
        2
    ) AS attendance_percentage,

    DATE_PART(
        'year',
        AGE(CURRENT_DATE, e.hire_date)
    ) AS total_experience_years

FROM employees e

JOIN departments d
    ON e.department_id = d.department_id

JOIN performance_reviews p
    ON e.employee_id = p.employee_id

JOIN attendance_monthly a
    ON e.employee_id = a.employee_id

GROUP BY
    e.employee_id,
    e.employee_name,
    d.department_name,
    e.hire_date

HAVING
    AVG(p.performance_score) > 4

    AND (
        SUM(a.present_days)::NUMERIC
        / SUM(a.working_days)
    ) * 100 > 90

    AND DATE_PART(
        'year',
        AGE(CURRENT_DATE, e.hire_date)
    ) > 3

ORDER BY avg_performance_score DESC;


/*
15. Salary Band Classification

Create salary bands:
Low, Medium, High, Executive */

WITH salary_percentile AS (
    SELECT
        e.employee_id,
        e.employee_name,
        d.department_name,
        s.base_salary,

        NTILE(4) OVER (
            ORDER BY s.base_salary
        ) AS salary_group

    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
    JOIN salary_history s
        ON e.employee_id = s.employee_id
)

SELECT
    employee_id,
    employee_name,
    department_name,
    base_salary,

    CASE
        WHEN salary_group = 1 THEN 'Low'
        WHEN salary_group = 2 THEN 'Medium'
        WHEN salary_group = 3 THEN 'High'
        WHEN salary_group = 4 THEN 'Executive'
    END AS salary_band

FROM salary_percentile
ORDER BY base_salary DESC;
	
/*
16. Running Salary Expense By Month
*/

SELECT
    DATE_TRUNC('month', effective_date) AS salary_month,

    SUM(base_salary) AS monthly_salary_expense,

    SUM(SUM(base_salary)) OVER (
        ORDER BY DATE_TRUNC('month', effective_date)
    ) AS cumulative_salary_expense

FROM salary_history

GROUP BY DATE_TRUNC('month', effective_date)

ORDER BY salary_month;


/*
17. Performance Trend Analysis
*/

WITH performance_trend AS (

    SELECT
        employee_id,
        review_date,
        performance_score,

        LAG(performance_score) OVER (
            PARTITION BY employee_id
            ORDER BY review_date
        ) AS previous_score

    FROM performance_reviews
)

SELECT
    e.employee_id,
    e.employee_name,
    pt.performance_score,
    pt.previous_score,

    CASE
        WHEN pt.performance_score > pt.previous_score
            THEN 'Improved'

        WHEN pt.performance_score < pt.previous_score
            THEN 'Declined'

        ELSE 'Stable'
    END AS performance_trend

FROM performance_trend pt

JOIN employees e
    ON pt.employee_id = e.employee_id

WHERE previous_score IS NOT NULL;


/*
18. Department Salary Share
*/

SELECT
    d.department_name,

    SUM(s.base_salary) AS department_salary,

    ROUND(
        SUM(s.base_salary) * 100.0
        / SUM(SUM(s.base_salary)) OVER (),
        2
    ) AS salary_share_percentage

FROM departments d

JOIN employees e
    ON d.department_id = e.department_id

JOIN salary_history s
    ON e.employee_id = s.employee_id

GROUP BY d.department_name

ORDER BY salary_share_percentage DESC;


/*
19. Employee Ranking Dashboard
*/

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,

    s.base_salary,
    p.performance_score,

    ROUND(
        (a.present_days::NUMERIC
        / a.working_days) * 100,
        2
    ) AS attendance_percentage,

    RANK() OVER (
        ORDER BY s.base_salary DESC
    ) AS salary_rank,

    DENSE_RANK() OVER (
        ORDER BY p.performance_score DESC
    ) AS performance_rank,

    RANK() OVER (
        ORDER BY
        (a.present_days::NUMERIC / a.working_days) DESC
    ) AS attendance_rank

FROM employees e

JOIN departments d
    ON e.department_id = d.department_id

JOIN salary_history s
    ON e.employee_id = s.employee_id

JOIN performance_reviews p
    ON e.employee_id = p.employee_id

JOIN attendance_monthly a
    ON e.employee_id = a.employee_id;


/*
20. Final Executive HR Dashboard Query
*/

WITH latest_salary AS (

    SELECT
        employee_id,
        base_salary,

        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC
        ) AS rn

    FROM salary_history
),

attendance_data AS (

    SELECT
        employee_id,

        ROUND(
            (SUM(present_days)::NUMERIC
            / SUM(working_days)) * 100,
            2
        ) AS attendance_percentage

    FROM attendance_monthly

    GROUP BY employee_id
),

latest_performance AS (

    SELECT
        employee_id,
        performance_score,

        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn

    FROM performance_reviews
),

last_hike AS (

    SELECT
        employee_id,
        MAX(effective_date) AS last_salary_hike

    FROM salary_history

    GROUP BY employee_id
)

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    j.job_title,

    ls.base_salary AS latest_salary,

    ad.attendance_percentage,

    lp.performance_score,

    RANK() OVER (
        ORDER BY ls.base_salary DESC
    ) AS salary_rank,

    DATE_PART(
        'year',
        AGE(CURRENT_DATE, e.hire_date)
    ) AS experience_years,

    CASE
        WHEN lp.performance_score > 4
         AND ad.attendance_percentage > 90
         AND DATE_PART(
                'year',
                AGE(CURRENT_DATE, e.hire_date)
             ) > 3

        THEN 'Eligible'

        ELSE 'Not Eligible'
    END AS promotion_eligibility,

    CASE
        WHEN lp.performance_score < 3
         AND ad.attendance_percentage < 80
         AND lh.last_salary_hike <
             CURRENT_DATE - INTERVAL '2 years'

        THEN 'High Risk'

        ELSE 'Low Risk'
    END AS attrition_risk

FROM employees e

JOIN departments d
    ON e.department_id = d.department_id

JOIN job_roles j
    ON e.job_id = j.job_id

JOIN latest_salary ls
    ON e.employee_id = ls.employee_id

JOIN attendance_data ad
    ON e.employee_id = ad.employee_id

JOIN latest_performance lp
    ON e.employee_id = lp.employee_id

JOIN last_hike lh
    ON e.employee_id = lh.employee_id

WHERE
    ls.rn = 1
    AND lp.rn = 1

ORDER BY salary_rank;
