CREATE PROCEDURE [dbo].[Sales by Year]
    @Beginning_Date datetime,
    @Ending_Date    datetime
AS
SELECT Orders.ShippedDate, Orders.OrderID, OS.Subtotal, DATENAME(yy, Orders.ShippedDate) AS [Year]
FROM   dbo.Orders
       INNER JOIN dbo.[Order Subtotals] AS OS ON Orders.OrderID = OS.OrderID
WHERE  Orders.ShippedDate BETWEEN @Beginning_Date AND @Ending_Date;
GO
