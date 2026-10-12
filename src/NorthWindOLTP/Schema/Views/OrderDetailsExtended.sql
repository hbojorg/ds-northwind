CREATE VIEW [dbo].[Order Details Extended] AS
SELECT OD.OrderID, OD.ProductID, Products.ProductName,
       OD.UnitPrice, OD.Quantity, OD.Discount,
       (CONVERT(money, (OD.UnitPrice * OD.Quantity * (1 - OD.Discount) / 100)) * 100) AS ExtendedPrice
FROM   dbo.Products
       INNER JOIN dbo.OrderDetails AS OD ON Products.ProductID = OD.ProductID;
GO
