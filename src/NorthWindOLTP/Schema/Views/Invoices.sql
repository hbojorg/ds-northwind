CREATE VIEW [dbo].[Invoices] AS
SELECT Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, Orders.ShipRegion, Orders.ShipPostalCode,
       Orders.ShipCountry, Orders.CustomerID, Customers.CompanyName AS CustomerName, Customers.Address, Customers.City,
       Customers.Region, Customers.PostalCode, Customers.Country,
       (Employees.FirstName + ' ' + Employees.LastName) AS Salesperson,
       Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Shippers.CompanyName AS ShipperName,
       OD.ProductID, Products.ProductName, OD.UnitPrice, OD.Quantity, OD.Discount,
       (CONVERT(money, (OD.UnitPrice * OD.Quantity * (1 - OD.Discount) / 100)) * 100) AS ExtendedPrice,
       Orders.Freight
FROM   dbo.Shippers
       INNER JOIN (dbo.Products
                   INNER JOIN ((dbo.Employees
                                INNER JOIN (dbo.Customers
                                            INNER JOIN dbo.Orders ON Customers.CustomerID = Orders.CustomerID)
                                        ON Employees.EmployeeID = Orders.EmployeeID)
                               INNER JOIN dbo.OrderDetails AS OD ON Orders.OrderID = OD.OrderID)
                           ON Products.ProductID = OD.ProductID)
               ON Shippers.ShipperID = Orders.ShipVia;
GO
