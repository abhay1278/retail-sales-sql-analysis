--creating a clean table

SELECT *
INTO online_retail_clean
FROM online_retail
WHERE 
    CustomerID IS NOT NULL
    AND InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0;

--Fixing Customer ID

SELECT 
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CAST(CustomerID AS INT) AS CustomerID,
    Country
INTO online_retail_clean2
FROM online_retail_clean;

--veryifying

SELECT TOP 10 * FROM online_retail_clean2;

--Creating Tables:

--1. Customer Table

SELECT DISTINCT
    CustomerID,
    Country
INTO Customers
FROM online_retail_clean2
SELECT TOP 10 * FROM Customers;

--2. Products Table 

SELECT DISTINCT
    StockCode AS ProductID,
    Description AS ProductName,
    UnitPrice
INTO Products
FROM online_retail_clean2
SELECT TOP 10 * FROM Products;

--3. Orders Table

SELECT DISTINCT
    InvoiceNo AS OrderID,
    CustomerID,
    InvoiceDate
INTO Orders
FROM online_retail_clean2
SELECT TOP 10 * FROM Orders;

--4. Order Details Table 

SELECT
    InvoiceNo AS OrderID,
    StockCode AS ProductID,
    Quantity
INTO Order_Details
FROM online_retail_clean2
SELECT TOP 10 * FROM Order_Details;

--TOTAL REVENUE

SELECT 
    SUM(P.UnitPrice * OD.Quantity) AS TotalRevenue
FROM Order_Details OD
JOIN Products P ON OD.ProductID = P.ProductID;

--REVENUE BY COUNTRY

SELECT 
    C.Country,
    SUM(P.UnitPrice * OD.Quantity) AS Revenue
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN Order_Details OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY C.Country
ORDER BY Revenue DESC;

--TOP 10 CUSTOMERS

SELECT TOP 10
    C.CustomerID,
    SUM(P.UnitPrice * OD.Quantity) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN Order_Details OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY C.CustomerID
ORDER BY TotalSpent DESC;

--TOP SELLING PRODUCTS

SELECT TOP 10
    P.ProductName,
    SUM(OD.Quantity) AS TotalQuantitySold
FROM Products P
JOIN Order_Details OD ON P.ProductID = OD.ProductID
GROUP BY P.ProductName
ORDER BY TotalQuantitySold DESC;

--MONTHLY SALES TREND

SELECT 
    YEAR(O.InvoiceDate) AS Year,
    MONTH(O.InvoiceDate) AS Month,
    SUM(P.UnitPrice * OD.Quantity) AS Revenue
FROM Orders O
JOIN Order_Details OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY YEAR(O.InvoiceDate), MONTH(O.InvoiceDate)
ORDER BY Year, Month;


--PRODUCTS NEVER ORDERED

SELECT ProductName
FROM Products
WHERE ProductID NOT IN (
    SELECT ProductID FROM Order_Details
);

