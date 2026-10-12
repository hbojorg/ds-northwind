-- =============================================================================
-- DimShipper: transportistas (SCD Tipo 1). Nueva dimension respecto a la
-- referencia BikeStores: permite analizar tiempos de entrega y flete por empresa.
-- =============================================================================
CREATE TABLE [dbo].[DimShipper]
(
    [ShipperSK]   [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED,
    [ShipperID]   [int]               NOT NULL,   -- clave de negocio (OLTP)
    [CompanyName] [nvarchar](40)      NOT NULL,
    [Phone]       [nvarchar](24)      NULL,
    [InsertedAt]  [datetime2](0)      NOT NULL CONSTRAINT [DF_DimShipper_InsertedAt] DEFAULT (SYSDATETIME()),
    [UpdatedAt]   [datetime2](0)      NULL
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_DimShipper_ShipperID] ON [dbo].[DimShipper] ([ShipperID] ASC);
GO
