CREATE VIEW [dbo].[Category Sales for 1997] AS
SELECT PS.CategoryName, SUM(PS.ProductSales) AS CategorySales
FROM   dbo.[Product Sales for 1997] AS PS
GROUP BY PS.CategoryName;
GO
