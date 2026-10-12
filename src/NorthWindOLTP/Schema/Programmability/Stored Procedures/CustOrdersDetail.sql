CREATE PROCEDURE [dbo].[CustOrdersDetail] @OrderID int
AS
SELECT P.ProductName,
       UnitPrice     = ROUND(OD.UnitPrice, 2),
       OD.Quantity,
       Discount      = CONVERT(int, OD.Discount * 100),
       ExtendedPrice = ROUND(CONVERT(money, OD.Quantity * (1 - OD.Discount) * OD.UnitPrice), 2)
FROM   dbo.Products AS P
       INNER JOIN dbo.OrderDetails AS OD ON OD.ProductID = P.ProductID
WHERE  OD.OrderID = @OrderID;
GO
