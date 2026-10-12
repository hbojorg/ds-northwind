-- =============================================================================
-- DimCustomer: clientes. SCD Tipo 2 en los atributos geograficos
-- (City, Region, Country); el resto de atributos son Tipo 1 (se sobreescriben).
-- Una fila por version de cliente; IsCurrent = 1 marca la version vigente.
-- La fila CustomerSK = -1 es el miembro "Unknown" (pedidos sin cliente).
-- =============================================================================
CREATE TABLE [dbo].[DimCustomer]
(
    [CustomerSK]           [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED,
    [CustomerID]           [nchar](5)          NOT NULL,                      -- clave de negocio (OLTP)
    [CompanyName]          [nvarchar](40)      NOT NULL,
    [ContactName]          [nvarchar](30)      NULL,
    [ContactTitle]         [nvarchar](30)      NULL,
    [Address]              [nvarchar](60)      NULL,
    [City]                 [nvarchar](15)      NULL,                          -- SCD2
    [Region]               [nvarchar](15)      NULL,                          -- SCD2
    [PostalCode]           [nvarchar](10)      NULL,
    [Country]              [nvarchar](15)      NULL,                          -- SCD2
    [Phone]                [nvarchar](24)      NULL,
    [Fax]                  [nvarchar](24)      NULL,
    [CustomerTypes]        [nvarchar](200)     NULL,                          -- lista de CustomerTypeID (N:M aplanado)
    [CustomerDemographics] [nvarchar](1000)    NULL,
    [ValidFrom]            [datetime2](0)      NOT NULL CONSTRAINT [DF_DimCustomer_ValidFrom] DEFAULT ('1900-01-01'),
    [ValidTo]              [datetime2](0)      NOT NULL CONSTRAINT [DF_DimCustomer_ValidTo]   DEFAULT ('9999-12-31'),
    [IsCurrent]            [bit]               NOT NULL CONSTRAINT [DF_DimCustomer_IsCurrent] DEFAULT (1),
    [InsertedAt]           [datetime2](0)      NOT NULL CONSTRAINT [DF_DimCustomer_InsertedAt] DEFAULT (SYSDATETIME()),
    [UpdatedAt]            [datetime2](0)      NULL
);
GO

CREATE NONCLUSTERED INDEX [IX_DimCustomer_CustomerID] ON [dbo].[DimCustomer] ([CustomerID] ASC, [IsCurrent] ASC) INCLUDE ([ValidFrom], [ValidTo]);
GO
