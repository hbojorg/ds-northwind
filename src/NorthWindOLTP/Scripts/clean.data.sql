-- =============================================================================
-- Utilidad: vacia todas las tablas de NorthWind respetando las FK y reinicia
-- los IDENTITY. NO se ejecuta en el post-deploy; usar solo en entornos de prueba.
-- =============================================================================
DELETE FROM dbo.OrderDetails;
DELETE FROM dbo.Orders;
DBCC CHECKIDENT ('dbo.Orders', RESEED, 0);
DELETE FROM dbo.EmployeeTerritories;
DELETE FROM dbo.Employees;
DBCC CHECKIDENT ('dbo.Employees', RESEED, 0);
DELETE FROM dbo.CustomerCustomerDemo;
DELETE FROM dbo.CustomerDemographics;
DELETE FROM dbo.Customers;
DELETE FROM dbo.Shippers;
DBCC CHECKIDENT ('dbo.Shippers', RESEED, 0);
DELETE FROM dbo.Products;
DBCC CHECKIDENT ('dbo.Products', RESEED, 0);
DELETE FROM dbo.Suppliers;
DBCC CHECKIDENT ('dbo.Suppliers', RESEED, 0);
DELETE FROM dbo.Categories;
DBCC CHECKIDENT ('dbo.Categories', RESEED, 0);
DELETE FROM dbo.Territories;
DELETE FROM dbo.Region;
GO
