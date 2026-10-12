CREATE PROCEDURE [dbo].[CustOrderHist] @CustomerID nchar(5)
AS
SELECT P.ProductName, Total = SUM(OD.Quantity)
FROM   dbo.Products     AS P
       INNER JOIN dbo.OrderDetails AS OD ON OD.ProductID = P.ProductID
       INNER JOIN dbo.Orders       AS O  ON O.OrderID    = OD.OrderID
       INNER JOIN dbo.Customers    AS C  ON C.CustomerID = O.CustomerID
WHERE  C.CustomerID = @CustomerID
GROUP BY P.ProductName;
GO
