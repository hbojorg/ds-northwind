CREATE VIEW [dbo].[Sales by Category] AS
SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName,
       SUM(ODE.ExtendedPrice) AS ProductSales
FROM   dbo.Categories
       INNER JOIN (dbo.Products
                   INNER JOIN (dbo.Orders
                               INNER JOIN dbo.[Order Details Extended] AS ODE ON Orders.OrderID = ODE.OrderID)
                           ON Products.ProductID = ODE.ProductID)
               ON Categories.CategoryID = Products.CategoryID
WHERE  Orders.OrderDate BETWEEN '19970101' AND '19971231'
GROUP BY Categories.CategoryID, Categories.CategoryName, Products.ProductName;
GO
