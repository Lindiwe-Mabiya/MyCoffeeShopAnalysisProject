--Check and analyse the raw data uploaded into the database BRIGHTLIGHT, schema COFFEESHOPANALYSIS, and table COFFEESHOP.
-- retrieve all the columns and values in the table
SELECT *
FROM BRIGHTLIGHTDB.COFFEESHOPANALYSIS.COFFEESHOP;

--The following code was used before the LOOKER STUDIO excel retrieval problem
--- PREVIOUS CODE

SELECT
-- Store ID is used to count the stores available
    STORE_ID,
-- Store locations is used to Group and Compare revenue for the 3 Branches
    STORE_LOCATION,

-- Product_ID and Product_Category is used to count the number of products and/or categories most sold
-- the REPLACE function is used to replace any "," (comma) with a space since excel devides columns using commas and google looker
    PRODUCT_ID,
    PRODUCT_CATEGORY,
    REPLACE(REPLACE(REPLACE(PRODUCT_DETAIL, ',', ''), CHAR(10), ''), CHAR(13), '') AS DETAILS_OF_PRODUCT,
    PRODUCT_TYPE,

--Transaction_ID is used to count transaction made per day or depending on the calenda set up
    TRANSACTION_ID,
-- Transaction_Date and Time is used to see the peaks, however will be cleaned
    TRANSACTION_DATE,
    TRANSACTION_TIME,

--Date is divided into day name, month name and day of month so to get clear times and days for better analysis
    DAYNAME(TRANSACTION_DATE) AS Day_Name,
    MONTHNAME(TRANSACTION_DATE) AS Month_Name,
    DAYOFMONTH(TRANSACTION_DATE) AS Day_of_Month,

-- Unit Price is used to calculate sales Revenue
-- If table has NULL values on this column, the NULLS will be replaced with the value 0 with the use of IFNULL
-- the quantity bought is multiplied by the price to get the total for the transaction
    UNIT_PRICE,
    TRANSACTION_QTY AS Total_Quantity_Per_Transaction,

    (IFNULL(UNIT_PRICE, 0) * TRANSACTION_QTY) AS Total_Revenue,

-- Time group is created to identify if it thransaction is in a Morning Comute, Mid-Morning,  Lunch time, or Late Afternoon
    CASE 
        WHEN TRANSACTION_TIME BETWEEN '06:00:00' AND '08:59:00' THEN 'Morning Commute'
        WHEN TRANSACTION_TIME BETWEEN '09:00:00' AND '11:59:00' THEN 'Mid-Morning'
        WHEN TRANSACTION_TIME BETWEEN '12:00:00' AND '13:59:00' THEN 'Lunchtime & Early Afternoon'
        ELSE 'Late Afternoon'
    END AS TRANSACTION_TIME_GROUP,

-- Spend group is created to identify is the spend is low, medium or high per purchace
    CASE 
        WHEN UNIT_PRICE <= 100 THEN 'Low Spend'
        WHEN UNIT_PRICE > 100 AND UNIT_PRICE <= 300 THEN 'Medium Spend'
        ELSE 'High Spend'
    END AS SPEND_GROUP,

-- times are grouped to identify if the hours of purchases are peak hour, second rush hour, or general business time to identify the hours in which revenue is made better
    CASE 
        WHEN TRANSACTION_TIME BETWEEN '06:00:00' AND '11:30:00' THEN 'Peak Hour'
        WHEN TRANSACTION_TIME BETWEEN '12:00:00' AND '13:00:00' THEN 'Second Rush Hour'
        ELSE 'General Business Time'
    END AS TRANSACTION_PEAK_GROUP

FROM BRIGHTLEARNDB.COFFEESHOPANALYSIS.COFFEESHOP
ORDER BY TRANSACTION_DATE, TRANSACTION_TIME, TRANSACTION_ID;


--- FINAL CODE
--- I COULD HAVE ALSO DONE IT WITH IFNULL
-- This code is like that obove however includes COALESC function

SELECT
    COALESCE(STORE_ID, 0) AS STORE_ID,
    COALESCE(STORE_LOCATION, 'N/A') AS STORE_LOCATION,
    
    COALESCE(PRODUCT_ID, 0) AS PRODUCT_ID,
    COALESCE(PRODUCT_CATEGORY, 'N/A') AS PRODUCT_CATEGORY,
    
    COALESCE(
        REPLACE(REPLACE(REPLACE(PRODUCT_DETAIL, ',', ''), CHAR(10), ''), CHAR(13), ''), 
        'N/A'
    ) AS DETAILS_OF_PRODUCT,
    COALESCE(PRODUCT_TYPE, 'N/A') AS PRODUCT_TYPE,
    
    COALESCE(TRANSACTION_ID, 0) AS TRANSACTION_ID,
    TRANSACTION_DATE,  
    TRANSACTION_TIME, 

    COALESCE(DAYNAME(TRANSACTION_DATE), 'N/A') AS Day_Name,
    COALESCE(MONTHNAME(TRANSACTION_DATE), 'N/A') AS Month_Name,
    COALESCE(DAYOFMONTH(TRANSACTION_DATE), 0) AS Day_of_Month,

    COALESCE(UNIT_PRICE, 0) AS UNIT_PRICE,
    COALESCE(TRANSACTION_QTY, 0) AS Total_Quantity_Per_Transaction,

    (COALESCE(UNIT_PRICE, 0) * COALESCE(TRANSACTION_QTY, 0)) AS Total_Revenue,

    CASE 
        WHEN TRANSACTION_TIME BETWEEN '06:00:00' AND '08:59:00' THEN 'Morning Commute'
        WHEN TRANSACTION_TIME BETWEEN '09:00:00' AND '11:59:00' THEN 'Mid-Morning'
        WHEN TRANSACTION_TIME BETWEEN '12:00:00' AND '13:59:00' THEN 'Lunchtime & Early Afternoon'
        ELSE 'Late Afternoon'
    END AS TRANSACTION_TIME_GROUP,

    CASE 
        WHEN COALESCE(UNIT_PRICE, 0) BETWEEN 1 AND 2 THEN 'Low Spend'
        WHEN COALESCE(UNIT_PRICE, 0)  BETWEEN 3 AND 4 THEN 'Medium Spend'
        ELSE 'High Spend'
    END AS SPEND_GROUP,

    CASE 
        WHEN TRANSACTION_TIME BETWEEN '06:00:00' AND '11:30:00' THEN 'Peak Hour'
        WHEN TRANSACTION_TIME BETWEEN '12:00:00' AND '13:00:00' THEN 'Second Rush Hour'
        ELSE 'General Business Time'
    END AS TRANSACTION_PEAK_GROUP

FROM BRIGHTLIGHTDB.COFFEESHOPANALYSIS.COFFEESHOP
GROUP BY ALL
ORDER BY TRANSACTION_DATE, TRANSACTION_TIME, TRANSACTION_ID;
