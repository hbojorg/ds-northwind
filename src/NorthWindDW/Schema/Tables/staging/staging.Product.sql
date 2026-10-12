-- Staging: resultado de NorthWind.dbo.GetProductChangesByRowVersion
CREATE TABLE [staging].[Product]
(
    [ProductID]           [int]           NOT NULL,
    [ProductName]         [nvarchar](40)  NOT NULL,
    [QuantityPerUnit]     [nvarchar](20)  NULL,
    [UnitPrice]           [money]         NULL,
    [UnitsInStock]        [smallint]      NULL,
    [UnitsOnOrder]        [smallint]      NULL,
    [ReorderLevel]        [smallint]      NULL,
    [Discontinued]        [bit]           NOT NULL,
    [CategoryID]          [int]           NULL,
    [CategoryName]        [nvarchar](15)  NULL,
    [CategoryDescription] [nvarchar](500) NULL,
    [SupplierID]          [int]           NULL,
    [SupplierName]        [nvarchar](40)  NULL,
    [SupplierContactName] [nvarchar](30)  NULL,
    [SupplierCity]        [nvarchar](15)  NULL,
    [SupplierRegion]      [nvarchar](15)  NULL,
    [SupplierCountry]     [nvarchar](15)  NULL
);
GO
