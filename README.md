# Data Engineering & Analysis: World Layoffs Dataset

## Project Overview
This project involves a full ETL (Extract, Transform, Load) pipeline and Exploratory Data Analysis (EDA) of a global company layoffs dataset. The goal was to transform over 2,000 messy records into a clean, query-ready format and then extract strategic business insights regarding global layoff trends from 2020 to 2023.

## Technologies Used
* **Database:** MySQL
* **Tool:** MySQL Workbench
* **Language:** SQL

---

## Phase 1: Data Cleaning (ETL)
The cleaning process was structured into five phases to ensure 100% data integrity:

### 1. Staging Table Creation
I created a sandbox environment (`layoffs_staging`) to perform transformations. This ensures the original "Source of Truth" remains untouched, a best practice in data engineering.

### 2. Duplicate Removal
Lacking a unique ID, I utilized a **CTE** and the `ROW_NUMBER()` window function partitioned across all columns. After identifying duplicates, I purged them and immediately dropped the auxiliary helper column to keep the schema lean.

### 3. Standardization
* **Company & Country:** Applied `TRIM` and fixed geographical inconsistencies (e.g., removing trailing periods in "United States.").
* **Industry Unification:** Consolidated variations (like "Crypto" vs "CryptoCurrency") into single master labels.
* **Data Typing:** Converted the `date` column from `TEXT` to a proper `DATE` type using `STR_TO_DATE`.

### 4. Handling Nulls and Blanks
* **Data Recovery:** Implemented a **Self-Join** to recover missing `industry` values by matching companies with existing valid records.
* **Quality Filter:** Removed records where both `total_laid_off` and `percentage_laid_off` were NULL, as they provided no actionable insights.

---

## Phase 2: Exploratory Data Analysis (EDA)
After cleaning, I explored the data to answer key business questions:

### 1. Rolling Totals & Momentum
By combining **CTEs** with **Window Functions**, I calculated the cumulative rolling total of layoffs month-over-month. 
* **Insight:** Identified the specific months in late 2022 and early 2023 where the volume of layoffs accelerated to critical mass.

### 2. Global Rankings by Year
I utilized two layers of **CTEs** and `DENSE_RANK()` to isolate the Top 5 companies with the most layoffs for each year (2020-2023).
* **Insight:** Discovered a shift from COVID-hit sectors (Travel/Retail) in 2020 to massive Big Tech restructuring (Google/Amazon/Microsoft) in 2023.

---

## Key SQL Techniques Demonstrated
* **Advanced Window Functions:** `ROW_NUMBER()`, `DENSE_RANK()`, and `SUM() OVER()`.
* **Complex Logic:** Multiple **CTEs** and **Self-Joins**.
* **ETL Best Practices:** Staging environments and schema optimization.
* **Data Storytelling:** Translating raw query results into business trends.

## Final Reflections
This project was a major milestone in strengthening my SQL foundations. My biggest challenge was mastering the interaction between CTEs and Window Functions. I've learned that data cleaning isn't just about deleting rows; it's about making strategic decisions to preserve data quality and preparing it to tell a story.

---

### Interactive Portfolio
This project is part of my technical portfolio. You can view an interactive and dynamic demonstration of this process at [delicato.pt](https://www.delicato.pt).
