-- Actualiza la marca de agua de un paquete (upsert) y registra el resultado.
CREATE PROCEDURE [etl].[UpdateLastPackageRowVersion]
(
    @PackageName    VARCHAR(50),
    @LastRowVersion BIGINT,
    @Status         VARCHAR(20) = 'Success'
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [etl].[PackageConfig]
    SET    LastRowVersion = @LastRowVersion,
           LastRunDate    = SYSDATETIME(),
           LastRunStatus  = @Status
    WHERE  PackageName = @PackageName;

    IF @@ROWCOUNT = 0
        INSERT INTO [etl].[PackageConfig] (PackageName, LastRowVersion, LastRunDate, LastRunStatus)
        VALUES (@PackageName, @LastRowVersion, SYSDATETIME(), @Status);
END
GO
