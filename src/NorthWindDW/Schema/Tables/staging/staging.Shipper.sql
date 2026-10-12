-- Staging: resultado de NorthWind.dbo.GetShipperChangesByRowVersion
CREATE TABLE [staging].[Shipper]
(
    [ShipperID]   [int]          NOT NULL,
    [CompanyName] [nvarchar](40) NOT NULL,
    [Phone]       [nvarchar](24) NULL
);
GO
