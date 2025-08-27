-- Create table

CREATE TABLE sales_store1(
transaction_id varchar(15),
customer_id varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(30),
product_category varchar(15),
quantiy varchar(15),
prce int,
payment_mode varchar(15),
purchase_date date,
time_of_purchase time,
status varchar(15) );


-------------------------


--Bulk insert
SET DATEFORMAT DMY
BULK INSERT sales_store1
From "C:\Users\Admin\Desktop\SQL_Portfolio\sales_store.csv"
WITH (Firstrow=2,
fieldterminator=',',
RowTerminator='\n'
);	

SELECT * FROM sales_store1

-------------------------

--Make copy of original table

SELECT * INTO Sales 
FROM sales_store1

SELECT * FROM sales

-------------------------

--Data cleaning---

--1.To check for duplicate

with cte as (
select *,
row_number() over(partition by transaction_id order by transaction_id) as RN
from Sales )
select * from cte
where rn>1


-------------------------


--Delete duplicate rows

with cte as (
select *,
row_number() over(partition by transaction_id order by transaction_id) as RN
from Sales )
Delete from cte
where rn=2

select * from Sales


-------------------------


--Step 2: Correction of Headers

exec sp_rename 'sales.quantiy','quantity','column'

exec sp_rename 'sales.prce','price','column'

select * from Sales

-------------------------

--Step 3:To check  Datatype

Select COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='SALES'


-------------------------


--Step 4:To check  Null values

--To check null values across all column

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, ' +
    'COUNT(*) AS NullCount ' +
    'FROM ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ' ' +
    'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
    ' UNION ALL '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

-------------------------

--Treating NULL values

Select * 
from Sales
where transaction_id is null
or
customer_id is null
or
customer_name is null
or
customer_age is null
or
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or
quantity is null
or
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or
status is null

-------------------------
--Delete outlier

Delete 
from  Sales
where transaction_id is null

---------------------
--Treating null values
select * from Sales
where customer_name='Ehsaan Ram'

Update Sales
set customer_id ='CUST9494'
where transaction_id ='TXN977900'

select * from Sales
where customer_name='Damini Raju'

Update Sales
set customer_id ='CUST1401'
where transaction_id ='TXN985663'

------

Select *
from Sales
where customer_id='CUST1003'


update Sales
set customer_name='Mahika Saini',customer_age=35,gender='M'
where customer_id='CUST1003'

------

--Step 5: Data Cleaning format

Select distinct gender
from Sales

update Sales
set gender= 'M'
where gender='Male'


update Sales
set gender= 'F'
where gender='Female'

-----

Select distinct payment_mode
from Sales

--replace  CC with Credit Card

update Sales
set payment_mode= 'Credit Card'
where payment_mode='CC'


----Data Analysis----

-- 1. What are the top 5 most selling products by quantity?

SELECT * FROM sales

SELECT DISTINCT status
from sales

SELECT TOP 5 product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC

--Business Problem: We don't know which products are most in demand.

--Business Impact: Helps prioritize stock and boost sales through targeted promotions.


--2. Which products are most frequently cancelled?

SELECT TOP 5 product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC

--Business Problem: Frequent cancellations affect revenue and customer trust.

--Business Impact: Identify poor-performing products to improve quality or remove from catalog.

--3. What time of the day has the highest number of purchases?

select * from sales
	
	SELECT 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS time_of_day,
		COUNT(*) AS total_orders
	FROM sales
	GROUP BY 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END
ORDER BY total_orders DESC
---------------------------------------------------------------------------------------------
SELECT 
	DATEPART(HOUR,time_of_purchase) AS Peak_time,
	COUNT(*) AS Total_orders
FROM sales
GROUP BY DATEPART(HOUR,time_of_purchase)
ORDER BY Peak_time

--Business Problem Solved: Find peak sales times.

--Business Impact: Optimize staffing, promotions, and server loads.
-----------------------------------------------------------------------------------------------------------

--4. Who are the top 5 highest spending customers?

SELECT * FROM sales

SELECT TOP 5 customer_name,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_spend
FROM sales 
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC

--Business Problem Solved: Identify VIP customers.

--Business Impact: Personalized offers, loyalty rewards, and retention.

-----------------------------------------------------------------------------------------------------------

--5. Which product categories generate the highest revenue?

SELECT * FROM sales

SELECT 
	product_category,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS Revenue
FROM sales 
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC

--Business Problem Solved: Identify top-performing product categories.

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

-----------------------------------------------------------------------------------------------------------


-- 6. What is the return/cancellation rate per product category?

SELECT * FROM sales
--cancellation
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS cancelled_percent
FROM sales 
GROUP BY product_category
ORDER BY cancelled_percent DESC

--Return
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS returned_percent
FROM sales 
GROUP BY product_category
ORDER BY returned_percent DESC

--Business Problem Solved: Monitor dissatisfaction trends per category.


---Business Impact: Reduce returns, improve product descriptions/expectations.
--Helps identify and fix product or logistics issues.

-----------------------------------------------------------------------------------------------------------
--7. What is the most preferred payment mode?

SELECT * FROM sales

SELECT payment_mode, COUNT(payment_mode) AS total_count
FROM sales 
GROUP BY payment_mode
ORDER BY total_count desc


--Business Problem Solved: Know which payment options customers prefer.

--Business Impact: Streamline payment processing, prioritize popular modes.

-----------------------------------------------------------------------------------------------------------

---8. How does age group affect purchasing behavior?

SELECT * FROM sales
--SELECT MIN(customer_age) ,MAX(customer_age)
--from sales

SELECT 
	CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_purchase
FROM sales 
GROUP BY CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
ORDER BY SUM(price*quantity) DESC

--Business Problem Solved: Understand customer demographics.

--Business Impact: Targeted marketing and product recommendations by age group.

-----------------------------------------------------------------------------------------------------------
--9. What’s the monthly sales trend?

SELECT * FROM sales
--Method 1

SELECT 
	FORMAT(purchase_date,'yyyy-MM') AS Month_Year,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
	SUM(quantity) AS total_quantity
FROM sales 
GROUP BY FORMAT(purchase_date,'yyyy-MM')

--Method 2
SELECT * FROM sales
	
	SELECT 
		--YEAR(purchase_date) AS Years,
		MONTH(purchase_date) AS Months,
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
		SUM(quantity) AS total_quantity
FROM sales
GROUP BY MONTH(purchase_date)
ORDER BY Months
--2023	1	₹ 46,28,608
--2024	1	₹ 3,39,442

SELECT(4628608+339442)--4968050

--Business Problem: Sales fluctuations go unnoticed.


--Business Impact: Plan inventory and marketing according to seasonal trends.




SELECT * FROM sales

SELECT
	FORMAT(purchase_date,'yyyy-MM') AS Purchased_Month_Year,
	SUM(price*quantity) AS totalsales,
	SUM(quantity) AS totalquantity
FROM sales 
GROUP BY FORMAT(purchase_date,'yyyy-MM')
ORDER BY Purchased_Month_Year ASC
-----------------------------------------------------------------------------------------------------------

SELECT
	--YEAR(purchase_date) AS years,
	MONTH(purchase_date) as months,
	SUM(price*quantity) AS totalsales
FROM sales 
GROUP BY MONTH(purchase_date)
--YEAR(purchase_date)
ORDER BY months ASC

--Business Problem: Sales fluctuations go unnoticed.

--Business Impact: Plan inventory and marketing according to seasonal trends.

-----------------------------------------------------------------------------------------------------------

-- 10. Are certain genders buying more specific product categories?

SELECT * from sales

--Method 1:

SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender

--Method 2

SELECT * 
FROM ( 
	SELECT gender, product_category
	FROM sales 
	) AS source_table
PIVOT (
	COUNT(gender)
	FOR gender IN ([M],[F])
	) AS pivot_table
ORDER BY product_category


--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.














