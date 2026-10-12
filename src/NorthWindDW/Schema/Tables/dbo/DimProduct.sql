-- =============================================================================
-- DimProduct: productos con categoria y proveedor desnormalizados (estrella pura,
-- sin DimCategory / DimSupplier). SCD Tipo 2 en UnitPrice (precio de lista),
-- Discontinued, CategoryName y SupplierName: permite analizar ventas con el
-- precio/categoria vigente en la fecha del pedido.
-- =============================================================================
CREATE TABLE [dbo].[DimProduct]
(
    [ProductSK]           [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED,
    [ProductID]           [int]               NOT NULL,                       -- clave de negocio (OLTP)
    [ProductName]         [nvarchar](40)      NOT NULL,
    [QuantityPerUnit]     [nvarchar](20)      NULL,
    [UnitPrice]           [decimal](19, 4)    NOT NULL CONSTRAINT [DF_DimProduct_UnitPrice] DEFAULT (0),   -- SCD2 (precio de lista)
    [UnitsInStock]        [smallint]          NULL,
    [UnitsOnOrder]        [smallint]          NULL,
    [ReorderLevel]        [smallint]          NULL,
    [Discontinued]        [bit]               NOT NULL CONSTRAINT [DF_DimProduct_Discontinued] DEFAULT (0), -- SCD2
    [ProductStatus]       [nvarchar](15)      NOT NULL CONSTRAINT [DF_DimProduct_ProductStatus] DEFAULT ('Active'),
    [CategoryID]          [int]               NULL,
    [CategoryName]        [nvarchar](15)      NULL,                           -- SCD2
    [CategoryDescription] [nvarchar](500)     NULL,
    [SupplierID]          [int]               NULL,
    [SupplierName]        [nvarchar](40)      NULL,                           -- SCD2
    [SupplierContactName] [nvarchar](30)      NULL,
    [SupplierCity]        [nvarchar](15)      NULL,
    [SupplierRegion]      [nvarchar](15)      NULL,
    [SupplierCountry]     [nvarchar](15)      NULL,
    [ValidFrom]           [datetime2](0)      NOT NULL CONSTRAINT [DF_DimProduct_ValidFrom] DEFAULT ('1900-01-01'),
    [ValidTo]             [datetime2](0)      NOT NULL CONSTRAINT [DF_DimProduct_ValidTo]   DEFAULT ('9999-12-31'),
    [IsCurrent]           [bit]               NOT NULL CONSTRAINT [DF_DimProduct_IsCurrent] DEFAULT (1),
    [InsertedAt]          [datetime2](0)      NOT NULL CONSTRAINT [DF_DimProduct_InsertedAt] DEFAULT (SYSDATETIME()),
    [UpdatedAt]           [datetime2](0)      NULL
);
GO

CREATE NONCLUSTERED INDEX [IX_DimProduct_ProductID] ON [dbo].[DimProduct] ([ProductID] ASC, [IsCurrent] ASC) INCLUDE ([ValidFrom], [ValidTo]);
GO
