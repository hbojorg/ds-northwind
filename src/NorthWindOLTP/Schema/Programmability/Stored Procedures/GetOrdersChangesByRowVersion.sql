-- =============================================================================
-- ETL: lineas de pedido (Orders x OrderDetails) nuevas o modificadas en el rango
-- de rowversion (@startRow, @endRow].
-- Granularidad: una fila por linea de pedido (OrderID + ProductID).
-- Se devuelven TODAS las lineas de un pedido cuando cambia la cabecera o
-- cualquiera de sus lineas, porque el prorrateo del flete (Freight) en el DW
-- depende del total del pedido.
-- Las claves de fecha (DateKey) se calculan en el DW, no aqui, para mantener
-- la logica de negocio del almacen en un solo lugar.
-- =============================================================================
CREATE PROCEDURE [dbo].[GetOrdersChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start ROWVERSION = CONVERT(ROWVERSION, @startRow),
            @end   ROWVERSION = CONVERT(ROWVERSION, @endRow);

    ;WITH ChangedOrders AS
    (
        SELECT o.OrderID
        FROM   dbo.Orders AS o
        WHERE  o.[rowversion] > @start AND o.[rowversion] <= @end
        UNION
        SELECT od.OrderID
        FROM   dbo.OrderDetails AS od
        WHERE  od.[rowversion] > @start AND od.[rowversion] <= @end
    )
    SELECT o.[OrderID],
           od.[ProductID],
           o.[CustomerID],
           o.[EmployeeID],
           ShipperID    = o.[ShipVia],
           OrderDate    = CONVERT(date, o.[OrderDate]),
           RequiredDate = CONVERT(date, o.[RequiredDate]),
           ShippedDate  = CONVERT(date, o.[ShippedDate]),
           o.[Freight],
           o.[ShipName],
           o.[ShipCity],
           o.[ShipRegion],
           o.[ShipPostalCode],
           o.[ShipCountry],
           od.[UnitPrice],
           od.[Quantity],
           od.[Discount]
    FROM   dbo.Orders AS o
           INNER JOIN dbo.OrderDetails AS od ON od.OrderID = o.OrderID
    WHERE  o.OrderID IN (SELECT OrderID FROM ChangedOrders);
END
GO
