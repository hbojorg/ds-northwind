CREATE TABLE [dbo].[Shippers]
(
    [ShipperID]   [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Shippers] PRIMARY KEY CLUSTERED,
    [CompanyName] [nvarchar](40)      NOT NULL,
    [Phone]       [nvarchar](24)      NULL,
    [rowversion]  [timestamp]         NULL
);
GO
