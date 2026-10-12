CREATE VIEW [dbo].[Order Subtotals] AS
SELECT OD.OrderID,
       SUM(CONVERT(money, (OD.UnitPrice * OD.Quantity * (1 - OD.Discount) / 100)) * 100) AS Subtotal
FROM   dbo.OrderDetails AS OD
GROUP BY OD.OrderID;
GO
