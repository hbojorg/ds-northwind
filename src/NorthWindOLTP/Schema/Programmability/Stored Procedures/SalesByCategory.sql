CREATE PROCEDURE [dbo].[SalesByCategory]
    @CategoryName nvarchar(15),
    @OrdYear      nvarchar(4) = '1998'
AS
IF @OrdYear != '1996' AND @OrdYear != '1997' AND @OrdYear != '1998'
BEGIN
    SELECT @OrdYear = '1998';
END

SELECT P.ProductName,
       TotalPurchase = ROUND(SUM(CONVERT(decimal(14,2), OD.Quantity * (1 - OD.Discount) * OD.UnitPrice)), 0)
FROM   dbo.OrderDetails AS OD
       INNER JOIN dbo.Orders     AS O ON OD.OrderID   = O.OrderID
       INNER JOIN dbo.Products   AS P ON OD.ProductID = P.ProductID
       INNER JOIN dbo.Categories AS C ON P.CategoryID = C.CategoryID
WHERE  C.CategoryName = @CategoryName
  AND  SUBSTRING(CONVERT(nvarchar(22), O.OrderDate, 111), 1, 4) = @OrdYear
GROUP BY P.ProductName
ORDER BY P.ProductName;
GO
