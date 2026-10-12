-- =============================================================================
-- etl.LoadFactSales
-- Carga incremental de FactSales (grano: linea de pedido).
--   1. Extrae a staging.Orders las lineas de pedidos nuevos o modificados.
--   2. Alimenta DimGeography con los destinos de envio no vistos.
--   3. Calcula medidas (bruto, descuento, neto, flete prorrateado, dias).
--   4. Resuelve claves surrogadas: en dimensiones SCD2 se toma la version
--      vigente en la FECHA DEL PEDIDO (no la ultima), y -1 si no existe.
--   5. MERGE en FactSales por (OrderID, ProductID): inserta o actualiza.
-- Requisito: ejecutar despues de las cargas de dimensiones.
-- =============================================================================
CREATE PROCEDURE [etl].[LoadFactSales]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @pkg       VARCHAR(50)   = 'FactSales',
            @startRV   BIGINT,
            @endRV     BIGINT,
            @logID     INT,
            @extracted INT = 0,
            @inserted  INT = 0,
            @updated   INT = 0,
            @now       DATETIME2(0) = SYSDATETIME();

    DECLARE @actions TABLE ([Action] NVARCHAR(10));

    SELECT @startRV = ISNULL(MAX(LastRowVersion), 0) FROM [etl].[PackageConfig] WHERE PackageName = @pkg;
    EXEC [etl].[GetSourceRowVersion] @endRV OUTPUT;
    EXEC [etl].[LogStart] @pkg, @startRV, @endRV, @logID OUTPUT;

    BEGIN TRY
        -- 1. Extraccion
        TRUNCATE TABLE [staging].[Orders];

        INSERT INTO [staging].[Orders]
               (OrderID, ProductID, CustomerID, EmployeeID, ShipperID, OrderDate, RequiredDate, ShippedDate, Freight,
                ShipName, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, UnitPrice, Quantity, Discount)
        EXEC [NorthWind].[dbo].[GetOrdersChangesByRowVersion] @startRV, @endRV;
        SET @extracted = @@ROWCOUNT;

        BEGIN TRANSACTION;

        -- 2. DimGeography (destinos nuevos)
        INSERT INTO [dbo].[DimGeography] (Country, Region, City, InsertedAt)
        SELECT DISTINCT ISNULL(s.ShipCountry, 'Unknown'), ISNULL(s.ShipRegion, 'N/A'), ISNULL(s.ShipCity, 'Unknown'), @now
        FROM   [staging].[Orders] AS s
        WHERE  NOT EXISTS (SELECT 1
                           FROM   [dbo].[DimGeography] AS g
                           WHERE  g.Country = ISNULL(s.ShipCountry, 'Unknown')
                             AND  g.Region  = ISNULL(s.ShipRegion,  'N/A')
                             AND  g.City    = ISNULL(s.ShipCity,    'Unknown'));

        -- 3. Medidas por linea y totales por pedido (para prorratear el flete)
        ;WITH Lines AS
        (
            SELECT s.*,
                   GrossAmount = CONVERT(DECIMAL(19,4), s.UnitPrice) * s.Quantity,
                   DiscountPct = CONVERT(DECIMAL(5,4), s.Discount)
            FROM   [staging].[Orders] AS s
        ),
        Lines2 AS
        (
            SELECT l.*,
                   DiscountAmount = ROUND(l.GrossAmount * l.DiscountPct, 4),
                   NetAmount      = l.GrossAmount - ROUND(l.GrossAmount * l.DiscountPct, 4)
            FROM   Lines AS l
        ),
        OrderTotals AS
        (
            SELECT OrderID, OrderNet = SUM(NetAmount), LineCount = COUNT(*)
            FROM   Lines2
            GROUP BY OrderID
        ),
        Src AS
        (
            SELECT l.OrderID,
                   l.ProductID,
                   OrderDateKey     = ISNULL(CONVERT(INT, CONVERT(CHAR(8), l.OrderDate,    112)), -1),
                   RequiredDateKey  = ISNULL(CONVERT(INT, CONVERT(CHAR(8), l.RequiredDate, 112)), -1),
                   ShippedDateKey   = ISNULL(CONVERT(INT, CONVERT(CHAR(8), l.ShippedDate,  112)), -1),
                   CustomerSK       = ISNULL(c.CustomerSK, -1),
                   EmployeeSK       = ISNULL(e.EmployeeSK, -1),
                   ProductSK        = ISNULL(p.ProductSK,  -1),
                   ShipperSK        = ISNULL(sh.ShipperSK, -1),
                   ShipGeographySK  = ISNULL(g.GeographySK, -1),
                   Quantity         = CONVERT(INT, l.Quantity),
                   UnitPrice        = CONVERT(DECIMAL(19,4), l.UnitPrice),
                   l.DiscountPct,
                   l.GrossAmount,
                   l.DiscountAmount,
                   l.NetAmount,
                   FreightAllocated = CASE WHEN ISNULL(t.OrderNet, 0) = 0
                                           THEN ROUND(CONVERT(DECIMAL(19,4), ISNULL(l.Freight, 0)) / t.LineCount, 4)
                                           ELSE ROUND(CONVERT(DECIMAL(19,4), ISNULL(l.Freight, 0)) * l.NetAmount / t.OrderNet, 4)
                                      END,
                   l.OrderDate,
                   l.RequiredDate,
                   l.ShippedDate,
                   DaysToShip = CONVERT(SMALLINT, DATEDIFF(DAY, l.OrderDate, l.ShippedDate)),
                   DaysLate   = CONVERT(SMALLINT, CASE WHEN l.ShippedDate IS NULL THEN NULL
                                                       WHEN l.ShippedDate > l.RequiredDate THEN DATEDIFF(DAY, l.RequiredDate, l.ShippedDate)
                                                       ELSE 0 END),
                   IsShipped  = CONVERT(BIT, CASE WHEN l.ShippedDate IS NULL THEN 0 ELSE 1 END),
                   IsLate     = CONVERT(BIT, CASE WHEN l.ShippedDate > l.RequiredDate THEN 1 ELSE 0 END)
            FROM   Lines2 AS l
                   INNER JOIN OrderTotals AS t ON t.OrderID = l.OrderID
                   -- SCD2: version vigente a la fecha del pedido (la ultima que inicio antes del fin de ese dia)
                   OUTER APPLY (SELECT TOP (1) d.CustomerSK
                                FROM   [dbo].[DimCustomer] AS d
                                WHERE  d.CustomerID = l.CustomerID
                                  AND  d.ValidFrom < DATEADD(DAY, 1, ISNULL(l.OrderDate, CONVERT(DATE, @now)))
                                ORDER BY d.ValidFrom DESC) AS c
                   OUTER APPLY (SELECT TOP (1) d.EmployeeSK
                                FROM   [dbo].[DimEmployee] AS d
                                WHERE  d.EmployeeID = l.EmployeeID
                                  AND  d.ValidFrom < DATEADD(DAY, 1, ISNULL(l.OrderDate, CONVERT(DATE, @now)))
                                ORDER BY d.ValidFrom DESC) AS e
                   OUTER APPLY (SELECT TOP (1) d.ProductSK
                                FROM   [dbo].[DimProduct] AS d
                                WHERE  d.ProductID = l.ProductID
                                  AND  d.ValidFrom < DATEADD(DAY, 1, ISNULL(l.OrderDate, CONVERT(DATE, @now)))
                                ORDER BY d.ValidFrom DESC) AS p
                   LEFT JOIN [dbo].[DimShipper]   AS sh ON sh.ShipperID = l.ShipperID
                   LEFT JOIN [dbo].[DimGeography] AS g  ON g.Country = ISNULL(l.ShipCountry, 'Unknown')
                                                       AND g.Region  = ISNULL(l.ShipRegion,  'N/A')
                                                       AND g.City    = ISNULL(l.ShipCity,    'Unknown')
        )
        -- 5. MERGE
        MERGE [dbo].[FactSales] AS f
        USING Src AS s ON (f.OrderID = s.OrderID AND f.ProductID = s.ProductID)
        WHEN MATCHED THEN
            UPDATE SET OrderDateKey     = s.OrderDateKey,
                       RequiredDateKey  = s.RequiredDateKey,
                       ShippedDateKey   = s.ShippedDateKey,
                       CustomerSK       = s.CustomerSK,
                       EmployeeSK       = s.EmployeeSK,
                       ProductSK        = s.ProductSK,
                       ShipperSK        = s.ShipperSK,
                       ShipGeographySK  = s.ShipGeographySK,
                       Quantity         = s.Quantity,
                       UnitPrice        = s.UnitPrice,
                       DiscountPct      = s.DiscountPct,
                       GrossAmount      = s.GrossAmount,
                       DiscountAmount   = s.DiscountAmount,
                       NetAmount        = s.NetAmount,
                       FreightAllocated = s.FreightAllocated,
                       OrderDate        = s.OrderDate,
                       RequiredDate     = s.RequiredDate,
                       ShippedDate      = s.ShippedDate,
                       DaysToShip       = s.DaysToShip,
                       DaysLate         = s.DaysLate,
                       IsShipped        = s.IsShipped,
                       IsLate           = s.IsLate,
                       UpdatedAt        = @now
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (OrderID, ProductID, OrderDateKey, RequiredDateKey, ShippedDateKey, CustomerSK, EmployeeSK, ProductSK, ShipperSK, ShipGeographySK,
                    Quantity, UnitPrice, DiscountPct, GrossAmount, DiscountAmount, NetAmount, FreightAllocated,
                    OrderDate, RequiredDate, ShippedDate, DaysToShip, DaysLate, IsShipped, IsLate, InsertedAt)
            VALUES (s.OrderID, s.ProductID, s.OrderDateKey, s.RequiredDateKey, s.ShippedDateKey, s.CustomerSK, s.EmployeeSK, s.ProductSK, s.ShipperSK, s.ShipGeographySK,
                    s.Quantity, s.UnitPrice, s.DiscountPct, s.GrossAmount, s.DiscountAmount, s.NetAmount, s.FreightAllocated,
                    s.OrderDate, s.RequiredDate, s.ShippedDate, s.DaysToShip, s.DaysLate, s.IsShipped, s.IsLate, @now)
        OUTPUT $action INTO @actions;

        SELECT @inserted = SUM(CASE WHEN [Action] = 'INSERT' THEN 1 ELSE 0 END),
               @updated  = SUM(CASE WHEN [Action] = 'UPDATE' THEN 1 ELSE 0 END)
        FROM   @actions;

        COMMIT TRANSACTION;

        EXEC [etl].[UpdateLastPackageRowVersion] @pkg, @endRV, 'Success';
        EXEC [etl].[LogEnd] @logID, @extracted, @inserted, @updated, 0, 'Success', NULL;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @err NVARCHAR(MAX) = ERROR_MESSAGE();
        EXEC [etl].[UpdateLastPackageRowVersion] @pkg, @startRV, 'Failed';
        EXEC [etl].[LogEnd] @logID, @extracted, @inserted, @updated, 0, 'Failed', @err;
        THROW;
    END CATCH
END
GO
