# HR Workforce Analytics Dashboard with Advanced SQL

## Overview

The **HR Workforce Analytics Dashboard with Advanced SQL** is an end-to-end enterprise-level analytics project built using **PostgreSQL** to simulate real-world Human Resource analytics workflows used by modern organizations.

This project focuses on solving complex HR business problems using:

* Advanced SQL Queries
* Window Functions
* CTEs (Common Table Expressions)
* Ranking Functions
* Date & Time Functions
* Statistical Analysis
* Workforce KPI Analysis
* Attrition Risk Detection
* Promotion Eligibility Analysis
* Salary Analytics
* Performance Tracking

The project was designed to replicate how data analysts work in large organizations while handling workforce data and executive HR reporting.

---

# Project Objectives

The main objective of this project is to:

* Analyze employee workforce data
* Build advanced HR analytical queries
* Generate business-driven insights
* Practice real-world SQL problem solving
* Simulate enterprise HR dashboard reporting
* Improve analytical thinking using PostgreSQL

---

# Database Schema

The project contains multiple relational tables simulating a real HR system.

## Tables Used

### 1. departments

Contains department-level information.

### 2. job_roles

Stores employee role hierarchy and salary bands.

### 3. employees

Core employee master table.

### 4. salary_history

Tracks employee salary changes over time.

### 5. performance_reviews

Contains quarterly/yearly performance evaluations.

### 6. attendance_monthly

Stores attendance, leave, and overtime data.

---

# Key Business Problems Solved

## Employee & Salary Analytics

* Top 10 Highest Paid Employees
* Department-wise Salary Analysis
* Salary Growth Tracking
* Salary Outlier Detection
* Salary Band Classification
* Department Salary Share Analysis
* Running Salary Expense Analysis

## Performance Analytics

* Top Performing Employees
* Performance Trend Analysis
* Best Performing Departments
* Promotion Eligibility Dashboard

## Attendance Analytics

* Monthly Attendance Percentage
* Consecutive Absence Detection
* Employees with 100% Attendance

## Workforce Intelligence

* Attrition Risk Detection
* Employee Experience Analysis
* Executive HR Dashboard Query
* Workforce KPI Monitoring

---

# Advanced SQL Concepts Used

## Window Functions

* ROW_NUMBER()
* RANK()
* DENSE_RANK()
* LAG()
* NTILE()
* SUM() OVER()
* AVG() OVER()

## PostgreSQL Functions

* DATE_TRUNC()
* AGE()
* DATE_PART()
* CURRENT_DATE
* ROUND()
* STDDEV()

## SQL Techniques

* CTEs (WITH Clause)
* Multi-table Joins
* Aggregations
* CASE WHEN Logic
* Statistical Analysis
* Ranking & Leaderboards
* Time-series Analysis
* Business KPI Calculations

---

# Sample Analytical Use Cases

## Attrition Risk Analysis

Identified employees at high risk of leaving the organization using:

* Low attendance
* Low performance
* No salary hike in recent years

## Promotion Eligibility System

Created a promotion recommendation logic using:

* Performance Score
* Attendance Percentage
* Employee Experience

## Salary Intelligence

Built analytical queries to detect:

* Salary outliers
* Salary growth trends
* Department salary distribution
* Executive compensation patterns

---

# Key Learning Outcomes

Through this project, I gained hands-on experience in:

* Writing complex SQL queries
* Solving real-world business problems
* Building enterprise-level analytical logic
* Using PostgreSQL for advanced analytics
* Workforce KPI reporting
* Data-driven HR decision making
* Window function optimization
* Analytical problem solving

---

# Example SQL Features Implemented

```sql
ROW_NUMBER() OVER (
    PARTITION BY employee_id
    ORDER BY effective_date DESC
)
```

```sql
LAG(base_salary) OVER (
    PARTITION BY employee_id
    ORDER BY effective_date
)
```

```sql
DENSE_RANK() OVER (
    PARTITION BY department_name
    ORDER BY performance_score DESC
)
```

---

# Project Highlights

* Built using enterprise-style HR datasets
* Solved 20+ advanced business case studies
* Implemented advanced PostgreSQL analytical queries
* Simulated executive HR dashboard reporting
* Focused on interview-level SQL problem solving
* Industry-oriented project architecture

---

# Business Insights Generated

The project helps organizations:

* Improve workforce productivity
* Identify promotion-ready employees
* Detect attrition risk employees
* Monitor department performance
* Optimize salary distribution
* Improve HR decision-making

---

# Author

## Arshad Sayyad

Aspiring Data Analyst skilled in:

* SQL
* python(pandas,numpy,seaborn,matplotib)
* PostgreSQL
* Excel
* Power BI
* Data Analytics
* Business Intelligence

---

# Connect With Me

## GitHub

[https://github.com/MrArshad07](https://github.com/MrArshad07)

## email

(arshadsayyad4033@gmail.com)

---
