# 📊 IBM HR Attrition Analysis

A relational data model and analytics pipeline built on the IBM HR Employee Attrition dataset (1,470 employees, 35 attributes), covering the full path from raw CSV to an interactive dashboard.

The dataset ships as a single flat file. I split it into five normalized tables joined on `EmployeeID`, wrote the SQL to analyze it, cross-checked the numbers in Excel, and built a Power BI report on top.

## 🧰 Stack

PostgreSQL, Microsoft Excel, Power BI (DAX)

## 🗂️ Data Model

| Table | Columns |
|---|---|
| `demographics` | Age, Gender, Department, JobRole, Education, MaritalStatus |
| `employment` | BusinessTravel, OverTime, YearsAtCompany, YearsInCurrentRole, TotalWorkingYears, YearsSinceLastPromotion |
| `compensation` | MonthlyIncome, PercentSalaryHike, StockOptionLevel |
| `satisfaction` | JobSatisfaction, EnvironmentSatisfaction, WorkLifeBalance, JobInvolvement, PerformanceRating |
| `attrition` | Attrition (Yes/No) |

`demographics` is the hub table. Everything else has a 1:1 relationship back to it through `EmployeeID`.

## 🗄️ SQL

`schema.sql` defines the five tables with foreign keys back to `demographics`.

`insight_queries.sql` has 18 queries, roughly in order of difficulty:
- Basic aggregates: headcount, average income by role, attrition counts
- Grouped comparisons: attrition rate by department, overtime, income band, tenure bucket
- Window functions and CTEs: `RANK()` on job roles, `NTILE()` for income quartiles, `LAG()` across tenure years, and a combined flight-risk flag (overtime + low satisfaction + no recent promotion)

There's also an `employee_full` view that joins all five tables, which is what Power BI/Excel pull from instead of five separate joins.

## 📈 Excel

Added three calculated columns to make the buckets consistent everywhere they're used:
- `TenureBucket` (0-2 / 3-5 / 6-10 / 10+ years)
- `IncomeBand` (<3000 / 3000-5999 / 6000-9999 / 10000+)
- `AttritionFlag` (1/0 version of Attrition, for quick averaging in pivots)

Used these in a few PivotTables to sanity-check the SQL output against a second method.

## 📊 Power BI

Five pages:

1. **Overview**: headline KPIs and the three strongest attrition drivers
2. **Department & Role**: attrition broken down by department and job role, plus a department × overtime view
3. **Compensation & Tenure**: income bands, tenure buckets, salary hike, and an income-vs-attrition scatter by role
4. **Satisfaction & Work-Life**: job satisfaction, environment, and work-life balance against attrition
5. **Risk Insights**: a high-risk flag (overtime + low satisfaction + no promotion in 3+ years), with a table of flagged employees and a comparison against the company-wide rate

### Overview
![Overview page](images/page1_overview.png)

### Department & Role
![Department & Role page](images/page2_department_role.png)

### Compensation & Tenure
![Compensation & Tenure page](images/page3_compensation_tenure.png)

### Satisfaction & Work-Life
![Satisfaction & Work-Life page](images/page4_satisfaction.png)

### Risk Insights
![Risk Insights page](images/page5_risk_insights.png)

## 🔑 What the data shows

Overall attrition sits at **16.1%**, but it's not evenly spread:

- **Overtime is the biggest single factor.** Employees working overtime leave at 30.5%, versus 10.4% for those who don't.
- **Tenure matters early.** Employees in their first two years leave at 29.8%, well above every other bracket.
- **Pay compounds it.** The lowest income band (<$3,000/month) sees 28.6% attrition.
- **Sales has the highest department-level attrition** at 20.6%, ahead of HR (19%) and R&D (13.8%).
- Employees who hit all three risk factors at once (overtime, low satisfaction, no recent promotion) leave at close to **2.8x** the baseline rate.

## 📁 Repository structure

```
├── data/
│   ├── demographics.csv
│   ├── employment.csv
│   ├── compensation.csv
│   ├── satisfaction.csv
│   └── attrition.csv
├── sql/
│   ├── schema.sql
│   └── insight_queries.sql
├── excel/
│   └── hr_attrition_analysis.xlsx
├── powerbi/
│   └── hr_attrition_dashboard.pbix
├── images/
│   ├── page1_overview.png
│   ├── page2_department_role.png
│   ├── page3_compensation_tenure.png
│   ├── page4_satisfaction.png
│   └── page5_risk_insights.png
└── README.md
```

## 🚀 Running it yourself

1. Run `sql/schema.sql` to create the tables.
2. Load the CSVs from `data/` in this order (child tables reference `demographics`, so it has to go first): `demographics → employment → compensation → satisfaction → attrition`.
3. Run `sql/insight_queries.sql` to reproduce the numbers above.
4. Open `powerbi/hr_attrition_dashboard.pbix`, point the data source at your local Postgres instance, and refresh.

## 📌 Notes

- Dataset: [IBM HR Analytics Employee Attrition & Performance](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset), synthetic data released by IBM.
- The original `EmployeeNumber` column was renamed to `EmployeeID` for consistency across all three tools.
