-- 1. Calculate the total sales for each month, considering only the months where the total sales exceed the overall average sales. Return the month and the total sales.

SELECT DATE_FORMAT(Order_datetime, '%Y-%m') AS Order_Month, ROUND(SUM(Price_in_USD),2) AS Monthly_Sales
FROM Jewelry.Jewelry_cleaned
GROUP BY Order_Month
HAVING Monthly_Sales > (
    SELECT AVG(Monthly_Sales)
    FROM (
        SELECT DATE_FORMAT(Order_datetime, '%Y-%m') AS Order_Month, SUM(Price_in_USD) AS Monthly_Sales
        FROM Jewelry.Jewelry_cleaned
        GROUP BY Order_Month
    ) AS Avg_Monthly_Sales
);

-- 2. Identify the top 5 months with the highest total sales revenue. Return the month and the total sales.

SELECT YEAR(Order_datetime) AS Order_Year, MONTH(Order_datetime) AS Order_Month, ROUND(SUM(Price_in_USD),2) AS Total_Sales
FROM Jewelry.Jewelry_cleaned
GROUP BY Order_Year, Order_Month
ORDER BY Total_Sales DESC
LIMIT 5;

-- 3. Calculate total sales for each combination of category alias and metal type, and rank it.

SELECT RANK()OVER(ORDER BY SUM(Price_in_USD)DESC) AS Ranking, Category_Alias, Metal_Type, ROUND(SUM(Price_in_USD),2) AS Total_Sales
FROM Jewelry.jewelry_cleaned
WHERE Metal_Type != 'n/a'
GROUP BY Category_Alias, Metal_Type;

-- 4. find out the rankings of the sales based on the gemstone_materials

SELECT 
    RANK() OVER (ORDER BY SUM(Price_in_USD) DESC) AS Ranking,
    Gemstone_Materials, 
    ROUND(SUM(Price_in_USD),2) AS Total_Sales
FROM Jewelry.Jewelry_cleaned
GROUP BY Gemstone_Materials
ORDER BY Ranking;

-- 5. Calculate the percentage of total sales contributed by each brand.

SELECT Brand_ID, 
       ROUND(SUM(Price_in_USD) / (SELECT SUM(Price_in_USD) FROM Jewelry.Jewelry_cleaned) * 100,2) AS Sales_Percentage
FROM Jewelry.Jewelry_cleaned
GROUP BY Brand_ID
ORDER BY Sales_Percentage DESC;

-- 6. Determine the hour of the day with 10 highest number of orders, ranked by ascending order.

SELECT RANK()Over(ORDER BY COUNT(*) DESC) as Rankings, HOUR(Order_datetime) AS Order_Hour, COUNT(*) AS Total_Orders
FROM Jewelry.Jewelry_cleaned
GROUP BY Order_Hour
ORDER BY Total_Orders DESC
LIMIT 10;

-- 7. Rank the day of the week with the highest number of orders.

SELECT RANK()OVER(ORDER BY COUNT(*)DESC) AS Ranking, DAYNAME(Order_datetime) AS Order_Day, COUNT(*) AS Total_Orders
FROM Jewelry.jewelry_cleaned
GROUP BY Order_Day
ORDER BY Total_Orders DESC;

-- 8. Determine the percentage of total sales contributed by each category alias.

SELECT Category_Alias, ROUND((SUM(Price_in_USD) / (SELECT SUM(Price_in_USD) FROM Jewelry.Jewelry_cleaned)) * 100 , 2) AS Sales_Percentage
FROM Jewelry.Jewelry_cleaned
GROUP BY Category_Alias
ORDER BY Sales_Percentage DESC;

-- 9. Find the brand with the highest total sales revenue in each month.

WITH Monthly_Brand_Sales AS (
    SELECT MONTH(Order_datetime) AS Order_Month, Brand_ID, ROUND(SUM(Price_in_USD),2) AS Total_Sales,
           ROW_NUMBER() OVER (PARTITION BY MONTH(Order_datetime) ORDER BY SUM(Price_in_USD) DESC) AS Ranking
    FROM Jewelry.jewelry_cleaned
    GROUP BY Order_Month, Brand_ID
)
SELECT Order_Month, Brand_ID, Total_Sales
FROM Monthly_Brand_Sales
WHERE Ranking = 1;

-- 10. Determine the percentage of repeated buyers.

SELECT 
    (Repeated_Buyers / Total_Users) * 100 AS Repeated_Buyers_Percentage
FROM (
    SELECT COUNT(DISTINCT User_ID) AS Total_Users
    FROM Jewelry.Jewelry_cleaned
) AS TotalUsers,
(
    SELECT COUNT(User_ID) AS Repeated_Buyers
    FROM (
        SELECT User_ID
        FROM Jewelry.Jewelry_cleaned
        GROUP BY User_ID
        HAVING COUNT(Order_ID) > 1
    ) AS Repeated_BuyersList
) AS RepeatedUsers;

-- 11. Find the percentage of orders that buy more than one item per order

WITH Orders_Per_Order AS (
    SELECT Order_ID, COUNT(*) AS Items_Per_Order
    FROM Jewelry.Jewelry_cleaned
    GROUP BY Order_ID
),
Total_Orders AS (
    SELECT COUNT(DISTINCT Order_ID) AS Total_Order_Count
    FROM Jewelry.Jewelry_cleaned
),
Orders_With_Multiple_Items AS (
    SELECT COUNT(DISTINCT Order_ID) AS Multiple_Items_Order_Count
    FROM Orders_Per_Order
    WHERE Items_Per_Order > 1
)
SELECT 
    (Multiple_Items_Order_Count / Total_Order_Count) * 100 AS Percentage_Orders_Multiple_Items
FROM 
    Orders_With_Multiple_Items, 
    Total_Orders;









