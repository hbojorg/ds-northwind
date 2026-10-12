CREATE VIEW [dbo].[Current Product List] AS
SELECT Product_List.ProductID, Product_List.ProductName
FROM   dbo.Products AS Product_List
WHERE  Product_List.Discontinued = 0;
GO
