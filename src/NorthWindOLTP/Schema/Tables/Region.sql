CREATE TABLE [dbo].[Region]
(
    [RegionID]          [int]       NOT NULL CONSTRAINT [PK_Region] PRIMARY KEY NONCLUSTERED,
    [RegionDescription] [nchar](50) NOT NULL,
    [rowversion]        [timestamp] NULL
);
GO
