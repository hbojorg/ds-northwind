-- =============================================================================
-- ETL: productos nuevos o modificados en el rango de rowversion (@startRow, @endRow].
-- Mejoras respecto a la version original:
--   * LEFT JOIN a Categories y Suppliers (ambas FK son NULLables en Products).
--   * Se desnormalizan tambien la descripcion de la categoria y la geografia
--     del proveedor, para que DimProduct sea una estrella pura (sin snowflake).
-- =============================================================================
CREATE PROCEDURE [dbo].[GetProductChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start ROWVERSION = CONVERT(ROWVERSION, @startRow),
            @end   ROWVERSION = CONVERT(ROWVERSION, @endRow);

    SELECT p.[ProductID],
           p.[ProductName],
           p.[QuantityPerUnit],
           p.[UnitPrice],
           p.[UnitsInStock],
           p.[UnitsOnOrder],
           p.[ReorderLevel],
           p.[Discontinued],
           p.[CategoryID],
           CategoryName        = c.[CategoryName],
           CategoryDescription = CONVERT(nvarchar(500), c.[Description]),
           p.[SupplierID],
           SupplierName        = s.[CompanyName],
           SupplierContactName = s.[ContactName],
           SupplierCity        = s.[City],
           SupplierRegion      = s.[Region],
           SupplierCountry     = s.[Country]
    FROM   dbo.Products AS p
           LEFT JOIN dbo.Categories AS c ON c.CategoryID = p.CategoryID
           LEFT JOIN dbo.Suppliers  AS s ON s.SupplierID = p.SupplierID
    WHERE  (p.[rowversion] > @start AND p.[rowversion] <= @end)
       OR  (c.[rowversion] > @start AND c.[rowversion] <= @end)
       OR  (s.[rowversion] > @start AND s.[rowversion] <= @end);
END
GO
