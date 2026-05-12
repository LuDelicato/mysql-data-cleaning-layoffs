# Data Cleaning in SQL - World Layoffs Dataset

## Project Overview
This project involves a comprehensive data cleaning process of a raw dataset containing global company layoffs. The primary objective was to transform inconsistent and unorganized data into a structured, reliable format suitable for exploratory data analysis and reporting.

## Technologies Used
* **Database:** MySQL
* **Tool:** MySQL Workbench
* **Language:** SQL

## Data Cleaning Steps
The cleaning process was divided into four key phases to ensure data integrity:

### 1. Staging Table Creation
A staging table was created to preserve the original raw data. All transformations were performed on this copy to ensure that the source data remained untouched and available for recovery if needed.

### 2. Duplicate Removal
Since the dataset lacked a unique primary key, duplicates were identified using a `CTE` (Common Table Expression) and the `ROW_NUMBER()` window function partitioned across all columns. Verified duplicates were then removed from the database.

### 3. Standardization
* **String Cleaning:** Applied `TRIM` to remove leading and trailing whitespaces from company names.
* **Industry Unification:** Standardized various labels (e.g., "Crypto", "CryptoCurrency") into a single consistent category.
* **Data Typing:** Converted the `date` column from a `TEXT` format into a proper `DATE` type using `STR_TO_DATE` to enable time-series analysis.
* **Geographical Correction:** Fixed inconsistencies in country names, such as removing trailing periods.

### 4. Handling Nulls and Blanks
* **Data Recovery:** Populated missing `industry` values by performing a `Self-Join`, matching companies with existing entries that had valid data.
* **Data Quality Filter:** Removed records where both `total_laid_off` and `percentage_laid_off` were null, as these entries provided no actionable insights for this project's scope.

## Key SQL Techniques Demonstrated
* **Window Functions:** `ROW_NUMBER()` for duplicate identification.
* **CTEs:** For structured and readable query logic.
* **Self-Joins:** For data recovery and population.
* **Schema Modification:** `ALTER TABLE` and `MODIFY COLUMN` for data type optimization.
* **Data Transformation:** `STR_TO_DATE`, `TRIM`, and `LIKE` operators.

## Final Result
The final dataset is cleaned, standardized, and optimized. The number of records was reduced to unique, high-quality entries, ensuring that any future analysis is based on accurate and consistent information.

---

### Interactive Portfolio
This project is part of my technical portfolio. You can view an interactive and dynamic demonstration of this process at [delicato.pt](https://www.delicato.pt).
