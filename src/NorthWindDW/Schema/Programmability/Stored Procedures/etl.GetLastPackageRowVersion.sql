-- Devuelve la marca de agua (ultimo rowversion procesado) de un paquete.
-- Compatible con el patron del proyecto de referencia (uso desde SSIS).
CREATE PROCEDURE [etl].[GetLastPackageRowVersion]
(
    @PackageName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LastRowVersion = ISNULL(MAX(LastRowVersion), 0)
    FROM   [etl].[PackageConfig]
    WHERE  PackageName = @PackageName;
END
GO
