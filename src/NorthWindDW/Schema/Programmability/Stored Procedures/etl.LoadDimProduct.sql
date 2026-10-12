-- =============================================================================
-- etl.LoadDimProduct
-- Carga incremental de DimProduct (SCD Tipo 2 en UnitPrice, Discontinued,
-- CategoryName y SupplierName). Mismo patron que etl.LoadDimCustomer.
-- =============================================================================
CREATE PROCEDURE [etl].[LoadDimProduct]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @pkg       VARCHAR(50)   = 'DimProduct',
            @startRV   BIGINT,
            @endRV     BIGINT,
            @logID     INT,
            @extracted INT = 0,
            @inserted  INT = 0,
            @updated   INT = 0,
            @expired   INT = 0,
            @now       DATETIME2(0) = SYSDATETIME();

    SELECT @startRV = ISNULL(MAX(LastRowVersion), 0) FROM [etl].[PackageConfig] WHERE PackageName = @pkg;
    EXEC [etl].[GetSourceRowVersion] @endRV OUTPUT;
    EXEC [etl].[LogStart] @pkg, @startRV, @endRV, @logID OUTPUT;

    BEGIN TRY
        TRUNCATE TABLE [staging].[Product];

        INSERT INTO [staging].[Product]
               (ProductID, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued,
                CategoryID, CategoryName, CategoryDescription, SupplierID, SupplierName, SupplierContactName, SupplierCity, SupplierRegion, SupplierCountry)
        EXEC [NorthWind].[dbo].[GetProductChangesByRowVersion] @startRV, @endRV;
        SET @extracted = @@ROWCOUNT;

        BEGIN TRANSACTION;

        -- Tipo 1
        UPDATE d
        SET    ProductName         = s.ProductName,
               QuantityPerUnit     = s.QuantityPerUnit,
               UnitsInStock        = s.UnitsInStock,
               UnitsOnOrder        = s.UnitsOnOrder,
               ReorderLevel        = s.ReorderLevel,
               CategoryID          = s.CategoryID,
               CategoryDescription = s.CategoryDescription,
               SupplierID          = s.SupplierID,
               SupplierContactName = s.SupplierContactName,
               SupplierCity        = s.SupplierCity,
               SupplierRegion      = s.SupplierRegion,
               SupplierCountry     = s.SupplierCountry,
               UpdatedAt           = @now
        FROM   [dbo].[DimProduct] AS d
               INNER JOIN [staging].[Product] AS s ON s.ProductID = d.ProductID
        WHERE  EXISTS (SELECT d.ProductName, d.QuantityPerUnit, d.UnitsInStock, d.UnitsOnOrder, d.ReorderLevel, d.CategoryID, d.CategoryDescription, d.SupplierID, d.SupplierContactName, d.SupplierCity, d.SupplierRegion, d.SupplierCountry
                       EXCEPT
                       SELECT s.ProductName, s.QuantityPerUnit, s.UnitsInStock, s.UnitsOnOrder, s.ReorderLevel, s.CategoryID, s.CategoryDescription, s.SupplierID, s.SupplierContactName, s.SupplierCity, s.SupplierRegion, s.SupplierCountry);
        SET @updated = @@ROWCOUNT;

        -- Tipo 2: expirar
        UPDATE d
        SET    ValidTo   = @now,
               IsCurrent = 0,
               UpdatedAt = @now
        FROM   [dbo].[DimProduct] AS d
               INNER JOIN [staging].[Product] AS s ON s.ProductID = d.ProductID
        WHERE  d.IsCurrent = 1
          AND  EXISTS (SELECT d.UnitPrice, d.Discontinued, d.CategoryName, d.SupplierName
                       EXCEPT
                       SELECT CONVERT(DECIMAL(19,4), ISNULL(s.UnitPrice, 0)), s.Discontinued, s.CategoryName, s.SupplierName);
        SET @expired = @@ROWCOUNT;

        -- Nuevas versiones
        INSERT INTO [dbo].[DimProduct]
               (ProductID, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued, ProductStatus,
                CategoryID, CategoryName, CategoryDescription, SupplierID, SupplierName, SupplierContactName, SupplierCity, SupplierRegion, SupplierCountry,
                ValidFrom, ValidTo, IsCurrent, InsertedAt)
        SELECT s.ProductID, s.ProductName, s.QuantityPerUnit, CONVERT(DECIMAL(19,4), ISNULL(s.UnitPrice, 0)), s.UnitsInStock, s.UnitsOnOrder, s.ReorderLevel, s.Discontinued,
               CASE WHEN s.Discontinued = 1 THEN 'Discontinued' ELSE 'Active' END,
               s.CategoryID, s.CategoryName, s.CategoryDescription, s.SupplierID, s.SupplierName, s.SupplierContactName, s.SupplierCity, s.SupplierRegion, s.SupplierCountry,
               ValidFrom = CASE WHEN EXISTS (SELECT 1 FROM [dbo].[DimProduct] AS d WHERE d.ProductID = s.ProductID) THEN @now ELSE CONVERT(DATETIME2(0), '1900-01-01') END,
               ValidTo   = CONVERT(DATETIME2(0), '9999-12-31'),
               IsCurrent = 1,
               InsertedAt = @now
        FROM   [staging].[Product] AS s
        WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[DimProduct] AS d WHERE d.ProductID = s.ProductID AND d.IsCurrent = 1);
        SET @inserted = @@ROWCOUNT;

        COMMIT TRANSACTION;

        EXEC [etl].[UpdateLastPackageRowVersion] @pkg, @endRV, 'Success';
        EXEC [etl].[LogEnd] @logID, @extracted, @inserted, @updated, @expired, 'Success', NULL;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @err NVARCHAR(MAX) = ERROR_MESSAGE();
        EXEC [etl].[UpdateLastPackageRowVersion] @pkg, @startRV, 'Failed';
        EXEC [etl].[LogEnd] @logID, @extracted, @inserted, @updated, @expired, 'Failed', @err;
        THROW;
    END CATCH
END
GO
