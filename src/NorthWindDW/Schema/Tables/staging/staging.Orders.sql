-- Staging: resultado de NorthWind.dbo.GetOrdersChangesByRowVersion (una fila por linea de pedido)
CREATE TABLE [staging].[Orders]
(
    [OrderID]        [int]          NOT NULL,
    [ProductID]      [int]          NOT NULL,
    [CustomerID]     [nchar](5)     NULL,
    [EmployeeID]     [int]          NULL,
    [ShipperID]      [int]          NULL,
    [OrderDate]      [date]         NULL,
    [RequiredDate]   [date]         NULL,
    [ShippedDate]    [date]         NULL,
    [Freight]        [money]        NULL,
    [ShipName]       [nvarchar](40) NULL,
    [ShipCity]       [nvarchar](15) NULL,
    [ShipRegion]     [nvarchar](15) NULL,
    [ShipPostalCode] [nvarchar](10) NULL,
    [ShipCountry]    [nvarchar](15) NULL,
    [UnitPrice]      [money]        NOT NULL,
    [Quantity]       [smallint]     NOT NULL,
    [Discount]       [real]         NOT NULL,
    CONSTRAINT [PK_staging_Orders] PRIMARY KEY CLUSTERED ([OrderID] ASC, [ProductID] ASC)
);
GO
