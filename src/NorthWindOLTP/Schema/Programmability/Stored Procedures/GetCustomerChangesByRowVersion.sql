-- =============================================================================
-- ETL: clientes nuevos o modificados en el rango de rowversion (@startRow, @endRow].
-- Mejoras respecto a la version original:
--   * Se corrige el JOIN g.CustomerTypeID = g.CustomerTypeID (producto cartesiano).
--   * Las demografias (N:M) se agregan con STRING_AGG para devolver UNA fila por
--     cliente y no multiplicar filas en la dimension.
--   * Los cambios en CustomerCustomerDemo / CustomerDemographics tambien
--     disparan la fila del cliente (EXISTS), sin duplicar.
-- =============================================================================
CREATE PROCEDURE [dbo].[GetCustomerChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start ROWVERSION = CONVERT(ROWVERSION, @startRow),
            @end   ROWVERSION = CONVERT(ROWVERSION, @endRow);

    SELECT c.[CustomerID],
           c.[CompanyName],
           c.[ContactName],
           c.[ContactTitle],
           c.[Address],
           c.[City],
           c.[Region],
           c.[PostalCode],
           c.[Country],
           c.[Phone],
           c.[Fax],
           CustomerTypes = (SELECT STRING_AGG(RTRIM(d.CustomerTypeID), ', ') WITHIN GROUP (ORDER BY d.CustomerTypeID)
                            FROM   dbo.CustomerCustomerDemo AS d
                            WHERE  d.CustomerID = c.CustomerID),
           CustomerDemographics = (SELECT STRING_AGG(CONVERT(nvarchar(max), g.CustomerDesc), ' | ') WITHIN GROUP (ORDER BY g.CustomerTypeID)
                                   FROM   dbo.CustomerCustomerDemo  AS d
                                   INNER JOIN dbo.CustomerDemographics AS g ON g.CustomerTypeID = d.CustomerTypeID
                                   WHERE  d.CustomerID = c.CustomerID)
    FROM   dbo.Customers AS c
    WHERE  (c.[rowversion] > @start AND c.[rowversion] <= @end)
       OR  EXISTS (SELECT 1
                   FROM   dbo.CustomerCustomerDemo AS d
                   LEFT JOIN dbo.CustomerDemographics AS g ON g.CustomerTypeID = d.CustomerTypeID
                   WHERE  d.CustomerID = c.CustomerID
                     AND ((d.[rowversion] > @start AND d.[rowversion] <= @end)
                       OR (g.[rowversion] > @start AND g.[rowversion] <= @end)));
END
GO
