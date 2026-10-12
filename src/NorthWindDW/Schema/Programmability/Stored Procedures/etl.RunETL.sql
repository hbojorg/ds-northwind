-- =============================================================================
-- etl.RunETL: orquestador. Ejecuta las cargas en el orden correcto
-- (dimensiones -> hecho). Es el unico punto de entrada para el SQL Agent Job.
--   @FullReload = 1  -> reinicia las marcas de agua y vuelve a procesar todo
--                       el origen (idempotente: no duplica filas).
-- Devuelve el resumen de la bitacora de esta corrida.
-- =============================================================================
CREATE PROCEDURE [etl].[RunETL]
(
    @FullReload BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @runStart DATETIME2(0) = SYSDATETIME();

    IF @FullReload = 1
        UPDATE [etl].[PackageConfig] SET LastRowVersion = 0;

    EXEC [etl].[LoadDimCustomer];
    EXEC [etl].[LoadDimEmployee];
    EXEC [etl].[LoadDimProduct];
    EXEC [etl].[LoadDimShipper];
    EXEC [etl].[LoadFactSales];

    SELECT LogID, PackageName, StartTime, EndTime,
           DurationSec = DATEDIFF(SECOND, StartTime, EndTime),
           StartRowVersion, EndRowVersion,
           RowsExtracted, RowsInserted, RowsUpdated, RowsExpired, Status, ErrorMessage
    FROM   [etl].[ETLLog]
    WHERE  StartTime >= @runStart
    ORDER BY LogID;
END
GO
