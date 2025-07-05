# 📊 End-to-End MySQL Project: World Layoffs Data Cleaning & Analysis

[![MySQL](https://img.shields.io/badge/Database-MySQL-blue.svg?logo=mysql&logoColor=white)](https://www.mysql.com/) 
[![MySQL Workbench](https://img.shields.io/badge/Tool-MySQL%20Workbench-4479A1?logo=mysql&logoColor=white)](https://dev.mysql.com/downloads/workbench/) 
[![VS Code](https://img.shields.io/badge/Editor-VSCode-007ACC.svg?logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/) 
[![CSV](https://img.shields.io/badge/Data-CSV-yellow?logo=csv&logoColor=black)](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

**“From raw data to insights: Cleaning and exploring layoff trends with MySQL”**

This project demonstrates an **end-to-end workflow** of importing, cleaning, and performing exploratory data analysis (EDA) on a real-world dataset using **MySQL**. The dataset includes records of layoffs from global companies during 2020–2025.  

The goal is to transform messy data into a clean, analysis-ready format and uncover key insights about layoff trends over time, by industry, company, and geography.

---

## 📂 Repository Structure
```
📦 mysql-end-to-end-layoffs-analysis
├── layoffs.csv # Raw dataset from Kaggle
├── Pooja_Data_cleaning_MySQL.sql # SQL script for data cleaning and transformation
├── Pooja_EDA_MySQL.sql # SQL script for exploratory data analysis
├── data_cleaning_table_data_import.jpg # Screenshot of CSV import step in MySQL Workbench
├── data_cleaning_table_data_import_success.jpg # Screenshot of import success in MySQL Workbench
└── README.md # Project overview and documentation
```

---

## 📖 Dataset
- **Source:** [Kaggle - World Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)  
- **Description:** Contains over 4,000 records of layoffs from global companies, including details such as:
  - Company name
  - Location
  - Total employees laid off
  - Industry
  - Date of layoffs
  - Percentage laid off
  - Funding raised
  - Source
  - Stage
  - Country

---

## 🧠 Project Workflow

### 🔹 1. Data Import
- Created a schema named `world_layoffs` using the **Table Data Import Wizard** in **MySQL Workbench**.  
- Imported `layoffs.csv` into MySQL successfully.  
  ![Successful Import](https://github.com/panditpooja/mysql-end-to-end-layoffs-analysis/blob/main/data_cleaning_table_data_import_success.jpg)
- Verified the imported schema and reviewed field types.  
- Kept the data in its **raw format** without any modifications at this stage, as all cleaning and transformations will be handled in the next steps using SQL queries.  
  ![First glance at the data](https://github.com/panditpooja/mysql-end-to-end-layoffs-analysis/blob/main/data_cleaning_table_data_import.jpg)

---

### 🔹 2. Data Cleaning (`Pooja_Data_cleaning_MySQL.sql`)
- **Deduplication:** Removed duplicate records using `ROW_NUMBER()` in a staging table.  
- **Standardization:**
  - Trimmed whitespaces.  
  - Fixed spelling issues.  
  - Ensured uniformity in date formats.  
  - Harmonized inconsistent industry and location names.  
  - Corrected data types where needed (e.g., converted `date` fields from `TEXT` to `DATE`).  
  - Cleaned `funds_raised` by removing `$` and `,` symbols and converting it to a numeric type.  
- **Handling Missing Values:**
  - Imputed missing industries using self-joins where possible.  
  - Updated blank fields to `NULL` for better consistency and easier validation.  
  - Dropped rows with incomplete key metrics.  
- **Removing Unnecessary Columns:**
  - In real-world projects, this step requires careful attention and approvals to ensure that removing columns does not impact related tables or downstream processes.

---

### 🔹 3. Exploratory Data Analysis (`Pooja_EDA_MySQL.sql`)
- **Overview:** Dataset tenure, key statistics, and records with 100% layoffs.  
- **Layoff Magnitudes:**
  - Top companies and industries by total layoffs.  
  - Countries and locations most impacted.  
- **Trends Over Time:**
  - Yearly and monthly layoffs.  
  - Companies with the highest layoffs per year.  
- **Rolling Analysis:**
  - Cumulative layoffs per month within each year.

---

## 📊 Key Insights

- 📅 **Dataset Tenure:** The dataset spans from **March 11, 2020**, to **June 4, 2025**, covering global layoff trends during and post-COVID-19.  
- 🏢 **Companies That Laid Off 100% of Employees:**  
  - Lists companies that completely shut down or laid off their entire workforce.  
- 📈 **Top 5 Single-Day Layoffs:**  
  - Highlights the biggest single-day layoff events by total employees affected.  
- 📊 **Top 10 Companies by Total Layoffs:**  
  - Shows which companies had the highest cumulative layoffs across all years.  
- 🏭 **Top 10 Industries Affected:**  
  - Identifies industries such as technology, retail, and finance most impacted by layoffs.  
- 🌎 **Top 10 Countries Affected:**  
  - Summarizes total layoffs per country, with the US, India, and others leading.  
- 🏙 **Top 10 Locations:**  
  - Focuses on cities with the highest layoffs, including key tech and financial hubs.  
- 📆 **Yearly Trends:**  
  - Illustrates how layoffs changed over time, identifying peaks and troughs per year.  
- 🏢 **Companies With Highest Layoffs Per Year:**  
  - Identifies the top company for layoffs in each year of the dataset.  
- 📆 **Rolling Monthly Analysis:**  
  - Examines cumulative layoffs on a monthly basis to uncover seasonal or economic patterns.  

---

## 🛠 Tools & Technologies
- **MySQL** – For data cleaning, transformation, and EDA.  
- **MySQL Workbench** – GUI for database management and query execution.  
- **VS Code** – For writing and organizing SQL scripts.  
- **Kaggle** – Dataset source (CSV file).  

---

## 🚀 How to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/panditpooja/mysql-end-to-end-layoffs-analysis.git
---

## 💡 Best Practices
In real-world corporate settings, **never modify the raw table directly**. Always create a staging table to perform cleaning and transformations. This ensures that if something goes wrong, you can revert back to the original raw data safely.

---
## ✍️ Author
Pooja Pandit  
Master’s Student in Information Science (Machine Learning)  
The University of Arizona
