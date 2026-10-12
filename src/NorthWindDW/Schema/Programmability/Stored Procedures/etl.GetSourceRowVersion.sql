-- Obtiene la marca de agua actual de la base OLTP (NorthWind.dbo.GetDatabaseRowVersion).
-- Se encapsula aqui para que la referencia a la base origen exista en un solo lugar.
CREATE PROCEDURE [etl].[GetSourceRowVersion]
(
    @RowVersion BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @t TABLE (DBTS BIGINT);

    INSERT INTO @t (DBTS)
    EXEC [NorthWind].[dbo].[GetDatabaseRowVersion];

    SELECT @RowVersion = ISNULL(MAX(DBTS), 0) FROM @t;
END
GO
