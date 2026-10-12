-- =============================================================================
-- ETL: transportistas nuevos o modificados en el rango (@startRow, @endRow].
-- (Nuevo: en el proyecto de referencia no existia una dimension de transportista.)
-- =============================================================================
CREATE PROCEDURE [dbo].[GetShipperChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start ROWVERSION = CONVERT(ROWVERSION, @startRow),
            @end   ROWVERSION = CONVERT(ROWVERSION, @endRow);

    SELECT s.[ShipperID],
           s.[CompanyName],
           s.[Phone]
    FROM   dbo.Shippers AS s
    WHERE  s.[rowversion] > @start AND s.[rowversion] <= @end;
END
GO
