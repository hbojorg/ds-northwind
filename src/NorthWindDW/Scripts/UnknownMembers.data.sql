-- =============================================================================
-- Miembros "Unknown" (clave -1) en todas las dimensiones.
-- Permiten que TODAS las FK de FactSales sean NOT NULL y que los pedidos sin
-- cliente/empleado/fecha de envio se agrupen de forma explicita en los reportes.
-- =============================================================================

-- DimDate (-1): fecha desconocida / aun no ocurrida (p. ej. pedidos no enviados)
IF NOT EXISTS (SELECT 1 FROM [dbo].[DimDate] WHERE DateKey = -1)
    INSERT INTO [dbo].[DimDate]
           (DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek, DayNameOfWeekES, DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear,
            [MonthName], MonthNameES, MonthNumberOfYear, YearMonth, YearMonthName, CalendarQuarter, CalendarQuarterName, CalendarSemester,
            CalendarYear, IsWeekend, IsLastDayOfMonth)
    VALUES (-1, '1900-01-01', 0, N'Unknown', N'Desconocido', 0, 0, 0, N'Unknown', N'Desconocido', 0, 0, N'N/A', 0, N'N/A', 0, 0, 0, 0);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[DimCustomer] WHERE CustomerSK = -1)
BEGIN
    SET IDENTITY_INSERT [dbo].[DimCustomer] ON;
    INSERT INTO [dbo].[DimCustomer] (CustomerSK, CustomerID, CompanyName, City, Region, Country, ValidFrom, ValidTo, IsCurrent)
    VALUES (-1, N'-1', N'Unknown', N'Unknown', N'N/A', N'Unknown', '1900-01-01', '9999-12-31', 1);
    SET IDENTITY_INSERT [dbo].[DimCustomer] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[DimEmployee] WHERE EmployeeSK = -1)
BEGIN
    SET IDENTITY_INSERT [dbo].[DimEmployee] ON;
    INSERT INTO [dbo].[DimEmployee] (EmployeeSK, EmployeeID, FullName, FirstName, LastName, Title, City, Region, Country, TerritoryCount, ValidFrom, ValidTo, IsCurrent)
    VALUES (-1, -1, N'Unknown', N'Unknown', N'Unknown', N'Unknown', N'Unknown', N'N/A', N'Unknown', 0, '1900-01-01', '9999-12-31', 1);
    SET IDENTITY_INSERT [dbo].[DimEmployee] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[DimProduct] WHERE ProductSK = -1)
BEGIN
    SET IDENTITY_INSERT [dbo].[DimProduct] ON;
    INSERT INTO [dbo].[DimProduct] (ProductSK, ProductID, ProductName, UnitPrice, Discontinued, ProductStatus, CategoryName, SupplierName, SupplierCountry, ValidFrom, ValidTo, IsCurrent)
    VALUES (-1, -1, N'Unknown', 0, 0, N'Unknown', N'Unknown', N'Unknown', N'Unknown', '1900-01-01', '9999-12-31', 1);
    SET IDENTITY_INSERT [dbo].[DimProduct] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[DimShipper] WHERE ShipperSK = -1)
BEGIN
    SET IDENTITY_INSERT [dbo].[DimShipper] ON;
    INSERT INTO [dbo].[DimShipper] (ShipperSK, ShipperID, CompanyName)
    VALUES (-1, -1, N'Unknown');
    SET IDENTITY_INSERT [dbo].[DimShipper] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[DimGeography] WHERE GeographySK = -1)
BEGIN
    SET IDENTITY_INSERT [dbo].[DimGeography] ON;
    INSERT INTO [dbo].[DimGeography] (GeographySK, Country, Region, City)
    VALUES (-1, N'Unknown', N'N/A', N'Unknown');
    SET IDENTITY_INSERT [dbo].[DimGeography] OFF;
END
GO
