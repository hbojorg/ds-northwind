-- =============================================================================
-- etl.LoadDimCustomer
-- Carga incremental de DimCustomer (SCD Tipo 2 en City/Region/Country).
--   1. Lee la marca de agua del paquete y la marca actual del OLTP.
--   2. Extrae los clientes cambiados a staging.Customer.
--   3. Tipo 1: sobreescribe atributos no historicos en TODAS las versiones.
--   4. Tipo 2: expira la version vigente si cambio un atributo historico.
--   5. Inserta versiones nuevas (clientes nuevos o expirados en el paso 4).
--   6. Avanza la marca de agua y registra la bitacora.
-- =============================================================================
CREATE PROCEDURE [etl].[LoadDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @pkg       VARCHAR(50)   = 'DimCustomer',
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
        -- 2. Extraccion
        TRUNCATE TABLE [staging].[Customer];

        INSERT INTO [staging].[Customer]
               (CustomerID, CompanyName, ContactName, ContactTitle, [Address], City, Region, PostalCode, Country, Phone, Fax, CustomerTypes, CustomerDemographics)
        EXEC [NorthWind].[dbo].[GetCustomerChangesByRowVersion] @startRV, @endRV;
        SET @extracted = @@ROWCOUNT;

        BEGIN TRANSACTION;

        -- 3. Tipo 1 (todas las versiones del cliente)
        UPDATE d
        SET    CompanyName          = s.CompanyName,
               ContactName          = s.ContactName,
               ContactTitle         = s.ContactTitle,
               [Address]            = s.[Address],
               PostalCode           = s.PostalCode,
               Phone                = s.Phone,
               Fax                  = s.Fax,
               CustomerTypes        = s.CustomerTypes,
               CustomerDemographics = s.CustomerDemographics,
               UpdatedAt            = @now
        FROM   [dbo].[DimCustomer] AS d
               INNER JOIN [staging].[Customer] AS s ON s.CustomerID = d.CustomerID
        WHERE  EXISTS (SELECT d.CompanyName, d.ContactName, d.ContactTitle, d.[Address], d.PostalCode, d.Phone, d.Fax, d.CustomerTypes, d.CustomerDemographics
                       EXCEPT
                       SELECT s.CompanyName, s.ContactName, s.ContactTitle, s.[Address], s.PostalCode, s.Phone, s.Fax, s.CustomerTypes, s.CustomerDemographics);
        SET @updated = @@ROWCOUNT;

        -- 4. Tipo 2: expirar version vigente con cambio historico
        UPDATE d
        SET    ValidTo   = @now,
               IsCurrent = 0,
               UpdatedAt = @now
        FROM   [dbo].[DimCustomer] AS d
               INNER JOIN [staging].[Customer] AS s ON s.CustomerID = d.CustomerID
        WHERE  d.IsCurrent = 1
          AND  EXISTS (SELECT d.City, d.Region, d.Country
                       EXCEPT
                       SELECT s.City, s.Region, s.Country);
        SET @expired = @@ROWCOUNT;

        -- 5. Nuevas versiones (clientes nuevos -> vigentes desde 1900; expirados -> desde ahora)
        INSERT INTO [dbo].[DimCustomer]
               (CustomerID, CompanyName, ContactName, ContactTitle, [Address], City, Region, PostalCode, Country, Phone, Fax,
                CustomerTypes, CustomerDemographics, ValidFrom, ValidTo, IsCurrent, InsertedAt)
        SELECT s.CustomerID, s.CompanyName, s.ContactName, s.ContactTitle, s.[Address], s.City, s.Region, s.PostalCode, s.Country, s.Phone, s.Fax,
               s.CustomerTypes, s.CustomerDemographics,
               ValidFrom = CASE WHEN EXISTS (SELECT 1 FROM [dbo].[DimCustomer] AS d WHERE d.CustomerID = s.CustomerID) THEN @now ELSE CONVERT(DATETIME2(0), '1900-01-01') END,
               ValidTo   = CONVERT(DATETIME2(0), '9999-12-31'),
               IsCurrent = 1,
               InsertedAt = @now
        FROM   [staging].[Customer] AS s
        WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[DimCustomer] AS d WHERE d.CustomerID = s.CustomerID AND d.IsCurrent = 1);
        SET @inserted = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- 6. Marca de agua + bitacora
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
