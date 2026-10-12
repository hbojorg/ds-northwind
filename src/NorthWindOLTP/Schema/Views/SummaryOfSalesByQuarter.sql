CREATE VIEW [dbo].[Summary of Sales by Quarter] AS
SELECT Orders.ShippedDate, Orders.OrderID, OS.Subtotal
FROM   dbo.Orders
       INNER JOIN dbo.[Order Subtotals] AS OS ON Orders.OrderID = OS.OrderID
WHERE  Orders.ShippedDate IS NOT NULL;
GO
