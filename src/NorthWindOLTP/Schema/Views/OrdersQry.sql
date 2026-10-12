CREATE VIEW [dbo].[Orders Qry] AS
SELECT Orders.OrderID, Orders.CustomerID, Orders.EmployeeID, Orders.OrderDate, Orders.RequiredDate,
       Orders.ShippedDate, Orders.ShipVia, Orders.Freight, Orders.ShipName, Orders.ShipAddress, Orders.ShipCity,
       Orders.ShipRegion, Orders.ShipPostalCode, Orders.ShipCountry,
       Customers.CompanyName, Customers.Address, Customers.City, Customers.Region, Customers.PostalCode, Customers.Country
FROM   dbo.Customers
       INNER JOIN dbo.Orders ON Customers.CustomerID = Orders.CustomerID;
GO
