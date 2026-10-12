CREATE VIEW [dbo].[Products by Category] AS
SELECT Categories.CategoryName, Products.ProductName, Products.QuantityPerUnit, Products.UnitsInStock, Products.Discontinued
FROM   dbo.Categories
       INNER JOIN dbo.Products ON Categories.CategoryID = Products.CategoryID
WHERE  Products.Discontinued <> 1;
GO
