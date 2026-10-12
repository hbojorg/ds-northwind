CREATE VIEW [dbo].[Sales Totals by Amount] AS
SELECT OS.Subtotal AS SaleAmount, Orders.OrderID, Customers.CompanyName, Orders.ShippedDate
FROM   dbo.Customers
       INNER JOIN (dbo.Orders
                   INNER JOIN dbo.[Order Subtotals] AS OS ON Orders.OrderID = OS.OrderID)
               ON Customers.CustomerID = Orders.CustomerID
WHERE  OS.Subtotal > 2500
  AND  Orders.ShippedDate BETWEEN '19970101' AND '19971231';
GO
