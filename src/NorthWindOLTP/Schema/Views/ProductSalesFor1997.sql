CREATE VIEW [dbo].[Product Sales for 1997] AS
SELECT Categories.CategoryName, Products.ProductName,
       SUM(CONVERT(money, (OD.UnitPrice * OD.Quantity * (1 - OD.Discount) / 100)) * 100) AS ProductSales
FROM   (dbo.Categories
        INNER JOIN dbo.Products ON Categories.CategoryID = Products.CategoryID)
       INNER JOIN (dbo.Orders
                   INNER JOIN dbo.OrderDetails AS OD ON Orders.OrderID = OD.OrderID)
               ON Products.ProductID = OD.ProductID
WHERE  Orders.ShippedDate BETWEEN '19970101' AND '19971231'
GROUP BY Categories.CategoryName, Products.ProductName;
GO
