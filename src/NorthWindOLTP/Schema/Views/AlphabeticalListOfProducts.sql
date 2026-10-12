CREATE VIEW [dbo].[Alphabetical list of products] AS
SELECT Products.*, Categories.CategoryName
FROM   dbo.Categories
       INNER JOIN dbo.Products ON Categories.CategoryID = Products.CategoryID
WHERE  Products.Discontinued = 0;
GO
