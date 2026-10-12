-- =============================================================================
-- etl.LoadDimShipper
-- Carga incremental de DimShipper (SCD Tipo 1: MERGE por clave de negocio).
-- =============================================================================
CREATE PROCEDURE [etl].[LoadDimShipper]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @pkg       VARCHAR(50)   = 'DimShipper',
            @startRV   BIGINT,
            @endRV     BIGINT,
            @logID     INT,
            @extracted INT = 0,
            @inserted  INT = 0,
            @updated   INT = 0,
            @now       DATETIME2(0) = SYSDATETIME();

    DECLARE @actions TABLE ([Action] NVARCHAR(10));

    SELECT @startRV = ISNULL(MAX(LastRowVersion), 0) FROM [etl].[PackageConfig] WHERE PackageName = @pkg;
    EXEC [etl].[GetSourceRowVersion] @endRV OUTPUT;
    EXEC [etl].[LogStart] @pkg, @startRV, @endRV, @logID OUTPUT;

    BEGIN TRY
        TRUNCATE TABLE [staging].[Shipper];

        INSERT INTO [staging].[Shipper] (ShipperID, CompanyName, Phone)
        EXEC [NorthWind].[dbo].[GetShipperChangesByRowVersion] @startRV, @endRV;
        SET @extracted = @@ROWCOUNT;

        BEGIN TRANSACTION;

        MERGE [dbo].[DimShipper] AS t
        USING [staging].[Shipper] AS s ON (t.ShipperID = s.ShipperID)
        WHEN MATCHED AND EXISTS (SELECT t.CompanyName, t.Phone EXCEPT SELECT s.CompanyName, s.Phone) THEN
            UPDATE SET CompanyName = s.CompanyName,
                       Phone       = s.Phone,
                       UpdatedAt   = @now
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ShipperID, CompanyName, Phone, InsertedAt)
            VALUES (s.ShipperID, s.CompanyName, s.Phone, @now)
        OUTPUT $action INTO @actions;

        SELECT @inserted = SUM(CASE WHEN [Action] = 'INSERT' THEN 1 ELSE 0 END),
               @updated  = SUM(CASE WHEN [Action] = 'UPDATE' THEN 1 ELSE 0 END)
        FROM   @actions;

        COMMIT TRANSACTION;

        EXEC [etl].[UpdateLastPackageRowVersion] @pkg, @endRV, 'Success';
        EXEC [etl].[LogEnd] @logID, @extracted, @inserted, @updated, 0, 'Success', NULL;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @err NVARCHAR(MAX) = ERROR_MESSAGE();
        EXEC [etl].[UpdateLastPackageRowVersion] @pkg, @startRV, 'Failed';
        EXEC [etl].[LogEnd] @logID, @extracted, @inserted, @updated, 0, 'Failed', @err;
        THROW;
    END CATCH
END
GO
