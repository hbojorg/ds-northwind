-- =============================================================================
-- etl.LoadDimEmployee
-- Carga incremental de DimEmployee (SCD Tipo 2 en Title, City, Region, Country
-- y jefe directo). Mismo patron que etl.LoadDimCustomer.
-- =============================================================================
CREATE PROCEDURE [etl].[LoadDimEmployee]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @pkg       VARCHAR(50)   = 'DimEmployee',
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
        TRUNCATE TABLE [staging].[Employee];

        INSERT INTO [staging].[Employee]
               (EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, [Address], City, Region, PostalCode, Country,
                HomePhone, Extension, ReportsTo, ManagerFullName, Territories, Regions, TerritoryCount)
        EXEC [NorthWind].[dbo].[GetEmployeeChangesByRowVersion] @startRV, @endRV;
        SET @extracted = @@ROWCOUNT;

        BEGIN TRANSACTION;

        -- Tipo 1
        UPDATE d
        SET    FullName        = s.FirstName + ' ' + s.LastName,
               FirstName       = s.FirstName,
               LastName        = s.LastName,
               TitleOfCourtesy = s.TitleOfCourtesy,
               BirthDate       = s.BirthDate,
               HireDate        = s.HireDate,
               [Address]       = s.[Address],
               PostalCode      = s.PostalCode,
               HomePhone       = s.HomePhone,
               Extension       = s.Extension,
               ManagerFullName = s.ManagerFullName,
               Territories     = s.Territories,
               Regions         = s.Regions,
               TerritoryCount  = s.TerritoryCount,
               UpdatedAt       = @now
        FROM   [dbo].[DimEmployee] AS d
               INNER JOIN [staging].[Employee] AS s ON s.EmployeeID = d.EmployeeID
        WHERE  EXISTS (SELECT d.FirstName, d.LastName, d.TitleOfCourtesy, d.BirthDate, d.HireDate, d.[Address], d.PostalCode, d.HomePhone, d.Extension, d.ManagerFullName, d.Territories, d.Regions, d.TerritoryCount
                       EXCEPT
                       SELECT s.FirstName, s.LastName, s.TitleOfCourtesy, s.BirthDate, s.HireDate, s.[Address], s.PostalCode, s.HomePhone, s.Extension, s.ManagerFullName, s.Territories, s.Regions, s.TerritoryCount);
        SET @updated = @@ROWCOUNT;

        -- Tipo 2: expirar
        UPDATE d
        SET    ValidTo   = @now,
               IsCurrent = 0,
               UpdatedAt = @now
        FROM   [dbo].[DimEmployee] AS d
               INNER JOIN [staging].[Employee] AS s ON s.EmployeeID = d.EmployeeID
        WHERE  d.IsCurrent = 1
          AND  EXISTS (SELECT d.Title, d.City, d.Region, d.Country, d.ReportsToEmployeeID
                       EXCEPT
                       SELECT s.Title, s.City, s.Region, s.Country, s.ReportsTo);
        SET @expired = @@ROWCOUNT;

        -- Nuevas versiones
        INSERT INTO [dbo].[DimEmployee]
               (EmployeeID, FullName, FirstName, LastName, Title, TitleOfCourtesy, BirthDate, HireDate, [Address], City, Region, PostalCode, Country,
                HomePhone, Extension, ReportsToEmployeeID, ManagerFullName, Territories, Regions, TerritoryCount, ValidFrom, ValidTo, IsCurrent, InsertedAt)
        SELECT s.EmployeeID, s.FirstName + ' ' + s.LastName, s.FirstName, s.LastName, s.Title, s.TitleOfCourtesy, s.BirthDate, s.HireDate, s.[Address], s.City, s.Region, s.PostalCode, s.Country,
               s.HomePhone, s.Extension, s.ReportsTo, s.ManagerFullName, s.Territories, s.Regions, s.TerritoryCount,
               ValidFrom = CASE WHEN EXISTS (SELECT 1 FROM [dbo].[DimEmployee] AS d WHERE d.EmployeeID = s.EmployeeID) THEN @now ELSE CONVERT(DATETIME2(0), '1900-01-01') END,
               ValidTo   = CONVERT(DATETIME2(0), '9999-12-31'),
               IsCurrent = 1,
               InsertedAt = @now
        FROM   [staging].[Employee] AS s
        WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[DimEmployee] AS d WHERE d.EmployeeID = s.EmployeeID AND d.IsCurrent = 1);
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
