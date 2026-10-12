-- =============================================================================
-- DimGeography: geografia de ENVIO del pedido (ShipCountry / ShipRegion /
-- ShipCity). Se alimenta desde los propios pedidos (no existe catalogo en el
-- OLTP). Permite comparar pais del cliente vs. pais de destino.
-- Region sin valor se guarda como 'N/A' para que la clave natural sea comparable.
-- =============================================================================
CREATE TABLE [dbo].[DimGeography]
(
    [GeographySK] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_DimGeography] PRIMARY KEY CLUSTERED,
    [Country]     [nvarchar](15)      NOT NULL,
    [Region]      [nvarchar](15)      NOT NULL CONSTRAINT [DF_DimGeography_Region] DEFAULT ('N/A'),
    [City]        [nvarchar](15)      NOT NULL,
    [InsertedAt]  [datetime2](0)      NOT NULL CONSTRAINT [DF_DimGeography_InsertedAt] DEFAULT (SYSDATETIME())
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_DimGeography_NK] ON [dbo].[DimGeography] ([Country] ASC, [Region] ASC, [City] ASC);
GO
