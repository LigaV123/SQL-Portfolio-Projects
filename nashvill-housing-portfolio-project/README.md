## Description
The "Data Cleaning with SQL Queries" project exemplifies the application of SQL queries in preprocessing 
and refining real estate data extracted from the NashvilleHousing database. 
The original data is located in excel file and inported to SQL Server Management Studio.
This project is designed to showcase proficiency in data cleaning techniques using SQL, 
addressing common challenges such as data inconsistencies, missing values, duplicates, and unstructured data formats.

## Key Objectives:
**1. Data Type Conversion:**
Utilizing SQL queries to convert data types, ensuring uniformity and compatibility across the dataset.
Examples include converting date-time fields to date format for easier manipulation and analysis.

**2. Populating Missing Data:**
Employing SQL join operations to populate missing or null values in essential fields such as property addresses.
Strategies include merging duplicate records and selecting appropriate replacement values from related records.

**3. Standardizing Address Fields:**
Breaking down complex address fields into individual components such as address, city, state, and ZIP code.
SQL string manipulation functions are utilized to extract and standardize address information for consistency and analysis.

**4. Standardizing Values:**
Standardizing categorical values to ensure consistency and ease of analysis. For instance,
converting 'Y' and 'N' values to 'Yes' and 'No' respectively in the 'SoldAsVacant' column for better interpretability.

**5. Removing Duplicates:**
Identifying and removing duplicate records using SQL window functions and common table expressions (CTEs).
Duplicate records are identified based on a combination of key fields and removed to maintain data integrity.

**6. Dropping Unused Columns:**
Streamlining the dataset by removing redundant or unused columns. SQL ALTER TABLE statements are employed
to drop columns that do not contribute to the analysis, enhancing data clarity and efficiency.
