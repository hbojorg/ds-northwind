CREATE VIEW [dbo].[Quarterly Orders] AS
SELECT DISTINCT Customers.CustomerID, Customers.CompanyName, Customers.City, Customers.Country
FROM   dbo.Customers
       RIGHT JOIN dbo.Orders ON Customers.CustomerID = Orders.CustomerID
WHERE  Orders.OrderDate BETWEEN '19970101' AND '19971231';
GO
