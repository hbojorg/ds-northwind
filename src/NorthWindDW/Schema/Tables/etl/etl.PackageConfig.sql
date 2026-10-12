-- =============================================================================
-- etl.PackageConfig: marca de agua (ultimo rowversion procesado) por paquete.
-- Equivale a dbo.PackageConfig del proyecto de referencia, con estado de la
-- ultima corrida.
-- =============================================================================
CREATE TABLE [etl].[PackageConfig]
(
    [PackageID]      [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_PackageConfig] PRIMARY KEY CLUSTERED,
    [PackageName]    [varchar](50)       NOT NULL,
    [LastRowVersion] [bigint]            NOT NULL CONSTRAINT [DF_PackageConfig_LastRowVersion] DEFAULT (0),
    [LastRunDate]    [datetime2](0)      NULL,
    [LastRunStatus]  [varchar](20)       NULL,
    CONSTRAINT [UX_PackageConfig_PackageName] UNIQUE NONCLUSTERED ([PackageName] ASC)
);
GO
