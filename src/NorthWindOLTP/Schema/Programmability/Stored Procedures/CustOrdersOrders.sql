CREATE PROCEDURE [dbo].[CustOrdersOrders] @CustomerID nchar(5)
AS
SELECT OrderID, OrderDate, RequiredDate, ShippedDate
FROM   dbo.Orders
WHERE  CustomerID = @CustomerID
ORDER BY OrderID;
GO
