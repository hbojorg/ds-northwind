-- =============================================================================
-- ETL: empleados nuevos o modificados en el rango de rowversion (@startRow, @endRow].
-- Mejoras respecto a la version original:
--   * La version original hacia INNER JOIN con EmployeeTerritories, lo que
--     devolvia N filas por empleado (uno por territorio) y excluia empleados
--     sin territorio. Ahora se devuelve UNA fila por empleado y los territorios
--     y regiones se agregan con STRING_AGG.
--   * Se incluye el nombre del jefe (ReportsTo) ya desnormalizado.
--   * No se exportan columnas binarias ni de texto largo (Photo, Notes).
-- =============================================================================
CREATE PROCEDURE [dbo].[GetEmployeeChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start ROWVERSION = CONVERT(ROWVERSION, @startRow),
            @end   ROWVERSION = CONVERT(ROWVERSION, @endRow);

    SELECT e.[EmployeeID],
           e.[LastName],
           e.[FirstName],
           e.[Title],
           e.[TitleOfCourtesy],
           BirthDate = CONVERT(date, e.[BirthDate]),
           HireDate  = CONVERT(date, e.[HireDate]),
           e.[Address],
           e.[City],
           e.[Region],
           e.[PostalCode],
           e.[Country],
           e.[HomePhone],
           e.[Extension],
           e.[ReportsTo],
           ManagerFullName = m.FirstName + ' ' + m.LastName,
           Territories = (SELECT STRING_AGG(RTRIM(t.TerritoryDescription), ', ') WITHIN GROUP (ORDER BY t.TerritoryDescription)
                          FROM   dbo.EmployeeTerritories AS et
                          INNER JOIN dbo.Territories AS t ON t.TerritoryID = et.TerritoryID
                          WHERE  et.EmployeeID = e.EmployeeID),
           Regions = (SELECT STRING_AGG(RTRIM(r.RegionDescription), ', ') WITHIN GROUP (ORDER BY r.RegionDescription)
                      FROM  (SELECT DISTINCT r.RegionID, r.RegionDescription
                             FROM   dbo.EmployeeTerritories AS et
                             INNER JOIN dbo.Territories AS t ON t.TerritoryID = et.TerritoryID
                             INNER JOIN dbo.Region      AS r ON r.RegionID    = t.RegionID
                             WHERE  et.EmployeeID = e.EmployeeID) AS r),
           TerritoryCount = (SELECT COUNT(*) FROM dbo.EmployeeTerritories AS et WHERE et.EmployeeID = e.EmployeeID)
    FROM   dbo.Employees AS e
           LEFT JOIN dbo.Employees AS m ON m.EmployeeID = e.ReportsTo
    WHERE  (e.[rowversion] > @start AND e.[rowversion] <= @end)
       OR  (m.[rowversion] > @start AND m.[rowversion] <= @end)
       OR  EXISTS (SELECT 1
                   FROM   dbo.EmployeeTerritories AS et
                   INNER JOIN dbo.Territories AS t ON t.TerritoryID = et.TerritoryID
                   INNER JOIN dbo.Region      AS r ON r.RegionID    = t.RegionID
                   WHERE  et.EmployeeID = e.EmployeeID
                     AND ((et.[rowversion] > @start AND et.[rowversion] <= @end)
                       OR (t.[rowversion]  > @start AND t.[rowversion]  <= @end)
                       OR (r.[rowversion]  > @start AND r.[rowversion]  <= @end)));
END
GO
