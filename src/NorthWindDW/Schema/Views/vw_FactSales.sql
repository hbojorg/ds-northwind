-- =============================================================================
-- vw_FactSales: vista "aplanada" del modelo estrella para consultas rapidas,
-- validaciones y conexion directa desde Power BI / Excel.
-- =============================================================================
CREATE VIEW [dbo].[vw_FactSales]
AS
SELECT f.OrderID,
       f.ProductID,
       -- Fechas
       od.FullDate            AS OrderDate,
       od.CalendarYear        AS OrderYear,
       od.CalendarQuarterName AS OrderQuarter,
       od.YearMonthName       AS OrderYearMonth,
       od.MonthName           AS OrderMonthName,
       rd.FullDate            AS RequiredDate,
       sd.FullDate            AS ShippedDate,
       -- Cliente
       c.CustomerID,
       c.CompanyName          AS CustomerName,
       c.City                 AS CustomerCity,
       c.Country              AS CustomerCountry,
       -- Vendedor
       e.EmployeeID,
       e.FullName             AS EmployeeName,
       e.Title                AS EmployeeTitle,
       e.ManagerFullName,
       -- Producto
       p.ProductName,
       p.CategoryName,
       p.SupplierName,
       p.SupplierCountry,
       p.UnitPrice            AS ListPrice,
       -- Transportista y destino
       s.CompanyName          AS ShipperName,
       g.Country              AS ShipCountry,
       g.Region               AS ShipRegion,
       g.City                 AS ShipCity,
       -- Medidas
       f.Quantity,
       f.UnitPrice,
       f.DiscountPct,
       f.GrossAmount,
       f.DiscountAmount,
       f.NetAmount,
       f.FreightAllocated,
       f.DaysToShip,
       f.DaysLate,
       f.IsShipped,
       f.IsLate
FROM   dbo.FactSales AS f
       INNER JOIN dbo.DimDate      AS od ON od.DateKey     = f.OrderDateKey
       INNER JOIN dbo.DimDate      AS rd ON rd.DateKey     = f.RequiredDateKey
       INNER JOIN dbo.DimDate      AS sd ON sd.DateKey     = f.ShippedDateKey
       INNER JOIN dbo.DimCustomer  AS c  ON c.CustomerSK   = f.CustomerSK
       INNER JOIN dbo.DimEmployee  AS e  ON e.EmployeeSK   = f.EmployeeSK
       INNER JOIN dbo.DimProduct   AS p  ON p.ProductSK    = f.ProductSK
       INNER JOIN dbo.DimShipper   AS s  ON s.ShipperSK    = f.ShipperSK
       INNER JOIN dbo.DimGeography AS g  ON g.GeographySK  = f.ShipGeographySK;
GO
