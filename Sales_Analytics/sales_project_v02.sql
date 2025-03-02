/*** SQL Sales Data Analytics Project  
	
	By: Matt Williams
	Completed: 03/22/2025
	Language: SQLite
	Dataset: https://www.kaggle.com/datasets/kyanyoga/sample-sales-data
	
***/

/*** 1. List the top 10 best selling products ***/

SELECT
	PRODUCTCODE,
	PRODUCTLINE AS [Product Line],
	sum(QUANTITYORDERED) AS [QTY SOLD]
FROM
	sales_data_sample
GROUP BY
	PRODUCTCODE
ORDER BY
	SUM(QUANTITYORDERED) DESC
LIMIT 10



/*** 2. List the top 10 highest grossing products ***/

SELECT
	PRODUCTCODE AS [Product],
	PRODUCTLINE AS [Product Line],
	ROUND(SUM(SALES)) as [Gross Sold]
FROM
	sales_data_sample
GROUP BY
	PRODUCTCODE
ORDER BY
	SUM(SALES) DESC
LIMIT 10



/*** 3. List the 5 worst selling products ***/

SELECT
	PRODUCTCODE AS [Product],
	PRODUCTLINE AS [Product Line],
	SUM(QUANTITYORDERED) AS [Quantity Sold]
FROM
	sales_data_sample
GROUP BY
	PRODUCTCODE
ORDER BY
	SUM(QUANTITYORDERED) ASC
LIMIT 5



/*** 4. What are our most successful productlines? ***/

SELECT
	PRODUCTLINE AS [Product Line],
	SUM(SALES) AS [Total Sales]
FROM
	sales_data_sample
GROUP BY
	PRODUCTLINE
ORDER BY
	SUM(SALES) DESC

	
	
/*** 5. Where is the highest demand for our products? ***/

SELECT
	CITY,
	COUNTRY,
	SUM(SALES) AS [Total Sales]
FROM
	sales_data_sample
GROUP BY
	CITY
ORDER BY
	SUM(SALES) DESC
LIMIT 10



/*** 6. How has the company sales changed over the duration of the dataset? ***/

SELECT
	YEAR_ID as [Year],
	ROUND(sum(SALES)) AS [Total Sales]
FROM
	sales_data_sample
GROUP BY
	YEAR_ID
ORDER BY
	YEAR_ID ASC

	
	
/*** 7. List our top 10 customers, how many orders they've placed, and
        how much they've purchased.                
***/

SELECT
	CUSTOMERNAME AS Customer,
	count(CUSTOMERNAME) AS [Total Orders],
	sum(SALES) AS [Total Sales]
FROM
	sales_data_sample
GROUP BY
	CUSTOMERNAME
ORDER BY
	count(CUSTOMERNAME) DESC
LIMIT
	10


	
/*** 8. Determine average sales by month for the entire dataset.

	Because the dataset includes 2.5 years of data, the average is calculated
	by dividing the total sales for each month (all Januaries for example) divided
	by the number of times that month occurs in the dataset. 

***/

SELECT
	-- define cases to replace numeric months with the name of the month
	CASE SD.MONTH_ID
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'February'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11	THEN 'November'
		WHEN 12 THEN 'December'
		else 'Err'
	END as [Month],
	round(SUM(SD.SALES)) AS [Total Sales in Month],               -- calculate total sales by month
	C.MONTH_COUNT AS [Months on Record],
	round(SUM(SD.SALES)/C.MONTH_COUNT) AS [Average Monthly Sales] -- avg sales = total sales / num of months on record
FROM
	sales_data_sample AS SD
INNER JOIN
	(/* Subquery to count number of times each calendar month appears
	    in the next subquery */
	 SELECT
		MONTH_ID,
		COUNT(MONTH_ID) AS MONTH_COUNT
	 FROM
		(-- Subquery to identify distint MONTH_ID-YEAR_ID combinations
		 SELECT
			DISTINCT MONTH_ID || '-' || YEAR_ID AS MO_YR,
			MONTH_ID
		 FROM
			sales_data_sample)
	GROUP BY
		MONTH_ID) AS C
	ON SD.MONTH_ID = C.MONTH_ID
GROUP BY
	SD.MONTH_ID
