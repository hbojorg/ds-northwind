CREATE VIEW [dbo].[Products Above Average Price] AS
SELECT Products.ProductName, Products.UnitPrice
FROM   dbo.Products
WHERE  Products.UnitPrice > (SELECT AVG(UnitPrice) FROM dbo.Products);
GO
