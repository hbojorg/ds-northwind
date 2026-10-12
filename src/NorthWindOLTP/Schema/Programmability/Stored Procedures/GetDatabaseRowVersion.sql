-- =============================================================================
-- ETL: devuelve la "marca de agua" (rowversion) actual de la base de datos.
-- El DW guarda este valor por paquete y en la siguiente corrida solo pide los
-- cambios con rowversion > ultima marca y <= marca actual.
-- MIN_ACTIVE_ROWVERSION()-1 evita perder filas de transacciones aun abiertas.
-- =============================================================================
CREATE PROCEDURE [dbo].[GetDatabaseRowVersion]
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    SELECT DBTS = (CONVERT(BIGINT, MIN_ACTIVE_ROWVERSION()) - 1);
END
GO
