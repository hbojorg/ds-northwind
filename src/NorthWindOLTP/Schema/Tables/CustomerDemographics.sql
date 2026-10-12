CREATE TABLE [dbo].[CustomerDemographics]
(
    [CustomerTypeID] [nchar](10)     NOT NULL CONSTRAINT [PK_CustomerDemographics] PRIMARY KEY NONCLUSTERED,
    [CustomerDesc]   [nvarchar](max) NULL,
    [rowversion]     [timestamp]     NULL
);
GO
