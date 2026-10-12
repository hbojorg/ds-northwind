CREATE TABLE [dbo].[Categories]
(
    [CategoryID]   [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED,
    [CategoryName] [nvarchar](15)      NOT NULL,
    [Description]  [nvarchar](max)     NULL,
    [Picture]      [image]             NULL,
    [rowversion]   [timestamp]         NULL
);
GO

CREATE NONCLUSTERED INDEX [CategoryName] ON [dbo].[Categories] ([CategoryName] ASC);
GO
