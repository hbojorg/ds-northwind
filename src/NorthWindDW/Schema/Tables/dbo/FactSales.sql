-- =============================================================================
-- FactSales: tabla de hechos de ventas. GRANO = una linea de pedido
-- (OrderID + ProductID). OrderID actua como dimension degenerada.
--
-- Claves de dimension (todas NOT NULL; -1 = miembro Unknown):
--   OrderDateKey / RequiredDateKey / ShippedDateKey  -> DimDate (role-playing)
--   CustomerSK, EmployeeSK, ProductSK, ShipperSK, ShipGeographySK
--
-- Medidas:
--   Quantity, UnitPrice (precio pactado en la linea), DiscountPct
--   GrossAmount      = UnitPrice * Quantity
--   DiscountAmount   = GrossAmount * DiscountPct
--   NetAmount        = GrossAmount - DiscountAmount
--   FreightAllocated = flete del pedido prorrateado por el NetAmount de la linea
--   DaysToShip       = ShippedDate - OrderDate   (NULL si no se ha enviado)
--   DaysLate         = dias de atraso vs RequiredDate (0 si llego a tiempo)
-- =============================================================================
CREATE TABLE [dbo].[FactSales]
(
    [OrderID]          [int]            NOT NULL,
    [ProductID]        [int]            NOT NULL,
    [OrderDateKey]     [int]            NOT NULL,
    [RequiredDateKey]  [int]            NOT NULL,
    [ShippedDateKey]   [int]            NOT NULL,
    [CustomerSK]       [int]            NOT NULL,
    [EmployeeSK]       [int]            NOT NULL,
    [ProductSK]        [int]            NOT NULL,
    [ShipperSK]        [int]            NOT NULL,
    [ShipGeographySK]  [int]            NOT NULL,
    [Quantity]         [int]            NOT NULL,
    [UnitPrice]        [decimal](19, 4) NOT NULL,
    [DiscountPct]      [decimal](5, 4)  NOT NULL,
    [GrossAmount]      [decimal](19, 4) NOT NULL,
    [DiscountAmount]   [decimal](19, 4) NOT NULL,
    [NetAmount]        [decimal](19, 4) NOT NULL,
    [FreightAllocated] [decimal](19, 4) NOT NULL,
    [OrderDate]        [date]           NULL,
    [RequiredDate]     [date]           NULL,
    [ShippedDate]      [date]           NULL,
    [DaysToShip]       [smallint]       NULL,
    [DaysLate]         [smallint]       NULL,
    [IsShipped]        [bit]            NOT NULL,
    [IsLate]           [bit]            NOT NULL,
    [InsertedAt]       [datetime2](0)   NOT NULL CONSTRAINT [DF_FactSales_InsertedAt] DEFAULT (SYSDATETIME()),
    [UpdatedAt]        [datetime2](0)   NULL,
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([OrderID] ASC, [ProductID] ASC),
    CONSTRAINT [FK_FactSales_DimDate_OrderDate]    FOREIGN KEY ([OrderDateKey])    REFERENCES [dbo].[DimDate]      ([DateKey]),
    CONSTRAINT [FK_FactSales_DimDate_RequiredDate] FOREIGN KEY ([RequiredDateKey]) REFERENCES [dbo].[DimDate]      ([DateKey]),
    CONSTRAINT [FK_FactSales_DimDate_ShippedDate]  FOREIGN KEY ([ShippedDateKey])  REFERENCES [dbo].[DimDate]      ([DateKey]),
    CONSTRAINT [FK_FactSales_DimCustomer]          FOREIGN KEY ([CustomerSK])      REFERENCES [dbo].[DimCustomer]  ([CustomerSK]),
    CONSTRAINT [FK_FactSales_DimEmployee]          FOREIGN KEY ([EmployeeSK])      REFERENCES [dbo].[DimEmployee]  ([EmployeeSK]),
    CONSTRAINT [FK_FactSales_DimProduct]           FOREIGN KEY ([ProductSK])       REFERENCES [dbo].[DimProduct]   ([ProductSK]),
    CONSTRAINT [FK_FactSales_DimShipper]           FOREIGN KEY ([ShipperSK])       REFERENCES [dbo].[DimShipper]   ([ShipperSK]),
    CONSTRAINT [FK_FactSales_DimGeography]         FOREIGN KEY ([ShipGeographySK]) REFERENCES [dbo].[DimGeography] ([GeographySK])
);
GO

CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey]    ON [dbo].[FactSales] ([OrderDateKey] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShippedDateKey]  ON [dbo].[FactSales] ([ShippedDateKey] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerSK]      ON [dbo].[FactSales] ([CustomerSK] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_EmployeeSK]      ON [dbo].[FactSales] ([EmployeeSK] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductSK]       ON [dbo].[FactSales] ([ProductSK] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperSK]       ON [dbo].[FactSales] ([ShipperSK] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipGeographySK] ON [dbo].[FactSales] ([ShipGeographySK] ASC);
GO
