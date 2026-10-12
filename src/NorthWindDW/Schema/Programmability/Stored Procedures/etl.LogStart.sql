-- Abre un registro en la bitacora del ETL y devuelve su identificador.
CREATE PROCEDURE [etl].[LogStart]
(
    @PackageName     VARCHAR(50),
    @StartRowVersion BIGINT,
    @EndRowVersion   BIGINT,
    @LogID           INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [etl].[ETLLog] (PackageName, StartTime, StartRowVersion, EndRowVersion, Status)
    VALUES (@PackageName, SYSDATETIME(), @StartRowVersion, @EndRowVersion, 'Running');

    SET @LogID = SCOPE_IDENTITY();
END
GO
