-- Staging: resultado de NorthWind.dbo.GetEmployeeChangesByRowVersion
CREATE TABLE [staging].[Employee]
(
    [EmployeeID]      [int]            NOT NULL,
    [LastName]        [nvarchar](20)   NOT NULL,
    [FirstName]       [nvarchar](10)   NOT NULL,
    [Title]           [nvarchar](30)   NULL,
    [TitleOfCourtesy] [nvarchar](25)   NULL,
    [BirthDate]       [date]           NULL,
    [HireDate]        [date]           NULL,
    [Address]         [nvarchar](60)   NULL,
    [City]            [nvarchar](15)   NULL,
    [Region]          [nvarchar](15)   NULL,
    [PostalCode]      [nvarchar](10)   NULL,
    [Country]         [nvarchar](15)   NULL,
    [HomePhone]       [nvarchar](24)   NULL,
    [Extension]       [nvarchar](4)    NULL,
    [ReportsTo]       [int]            NULL,
    [ManagerFullName] [nvarchar](31)   NULL,
    [Territories]     [nvarchar](1000) NULL,
    [Regions]         [nvarchar](200)  NULL,
    [TerritoryCount]  [int]            NOT NULL
);
GO
