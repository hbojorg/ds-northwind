CREATE PROCEDURE [dbo].[Employee Sales by Country]
    @Beginning_Date datetime,
    @Ending_Date    datetime
AS
SELECT Employees.Country, Employees.LastName, Employees.FirstName, Orders.ShippedDate, Orders.OrderID,
       OS.Subtotal AS SaleAmount
FROM   dbo.Employees
       INNER JOIN (dbo.Orders
                   INNER JOIN dbo.[Order Subtotals] AS OS ON Orders.OrderID = OS.OrderID)
               ON Employees.EmployeeID = Orders.EmployeeID
WHERE  Orders.ShippedDate BETWEEN @Beginning_Date AND @Ending_Date;
GO
