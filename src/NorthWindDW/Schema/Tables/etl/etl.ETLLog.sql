-- =============================================================================
-- etl.ETLLog: bitacora de cada ejecucion de paquete (auditoria y soporte).
-- =============================================================================
CREATE TABLE [etl].[ETLLog]
(
    [LogID]           [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_ETLLog] PRIMARY KEY CLUSTERED,
    [PackageName]     [varchar](50)       NOT NULL,
    [StartTime]       [datetime2](0)      NOT NULL CONSTRAINT [DF_ETLLog_StartTime] DEFAULT (SYSDATETIME()),
    [EndTime]         [datetime2](0)      NULL,
    [StartRowVersion] [bigint]            NULL,
    [EndRowVersion]   [bigint]            NULL,
    [RowsExtracted]   [int]               NULL,
    [RowsInserted]    [int]               NULL,
    [RowsUpdated]     [int]               NULL,
    [RowsExpired]     [int]               NULL,
    [Status]          [varchar](20)       NOT NULL CONSTRAINT [DF_ETLLog_Status] DEFAULT ('Running'),
    [ErrorMessage]    [nvarchar](max)     NULL
);
GO
