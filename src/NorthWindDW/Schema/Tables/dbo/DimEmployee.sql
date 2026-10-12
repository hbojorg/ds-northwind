-- =============================================================================
-- DimEmployee: vendedores. SCD Tipo 2 en Title, City, Region, Country y jefe
-- (ReportsToEmployeeID). Territorios y regiones de venta se aplanan en listas
-- (STRING_AGG) para evitar el snowflake Employees -> EmployeeTerritories ->
-- Territories -> Region y la multiplicacion de filas.
-- =============================================================================
CREATE TABLE [dbo].[DimEmployee]
(
    [EmployeeSK]          [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED,
    [EmployeeID]          [int]               NOT NULL,                       -- clave de negocio (OLTP)
    [FullName]            [nvarchar](31)      NOT NULL,
    [FirstName]           [nvarchar](10)      NOT NULL,
    [LastName]            [nvarchar](20)      NOT NULL,
    [Title]               [nvarchar](30)      NULL,                           -- SCD2
    [TitleOfCourtesy]     [nvarchar](25)      NULL,
    [BirthDate]           [date]              NULL,
    [HireDate]            [date]              NULL,
    [Address]             [nvarchar](60)      NULL,
    [City]                [nvarchar](15)      NULL,                           -- SCD2
    [Region]              [nvarchar](15)      NULL,                           -- SCD2
    [PostalCode]          [nvarchar](10)      NULL,
    [Country]             [nvarchar](15)      NULL,                           -- SCD2
    [HomePhone]           [nvarchar](24)      NULL,
    [Extension]           [nvarchar](4)       NULL,
    [ReportsToEmployeeID] [int]               NULL,                           -- SCD2
    [ManagerFullName]     [nvarchar](31)      NULL,
    [Territories]         [nvarchar](1000)    NULL,
    [Regions]             [nvarchar](200)     NULL,
    [TerritoryCount]      [int]               NOT NULL CONSTRAINT [DF_DimEmployee_TerritoryCount] DEFAULT (0),
    [ValidFrom]           [datetime2](0)      NOT NULL CONSTRAINT [DF_DimEmployee_ValidFrom] DEFAULT ('1900-01-01'),
    [ValidTo]             [datetime2](0)      NOT NULL CONSTRAINT [DF_DimEmployee_ValidTo]   DEFAULT ('9999-12-31'),
    [IsCurrent]           [bit]               NOT NULL CONSTRAINT [DF_DimEmployee_IsCurrent] DEFAULT (1),
    [InsertedAt]          [datetime2](0)      NOT NULL CONSTRAINT [DF_DimEmployee_InsertedAt] DEFAULT (SYSDATETIME()),
    [UpdatedAt]           [datetime2](0)      NULL
);
GO

CREATE NONCLUSTERED INDEX [IX_DimEmployee_EmployeeID] ON [dbo].[DimEmployee] ([EmployeeID] ASC, [IsCurrent] ASC) INCLUDE ([ValidFrom], [ValidTo]);
GO
