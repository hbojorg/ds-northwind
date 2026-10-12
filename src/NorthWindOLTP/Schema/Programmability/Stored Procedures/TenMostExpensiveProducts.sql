CREATE PROCEDURE [dbo].[Ten Most Expensive Products]
AS
SELECT TOP (10) Products.ProductName AS TenMostExpensiveProducts, Products.UnitPrice
FROM   dbo.Products
ORDER BY Products.UnitPrice DESC;
GO
