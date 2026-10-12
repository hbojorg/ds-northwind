-- Datos de dbo.Categories  (8 filas)  - generado por tools\Export-NorthWindData.ps1
-- Idempotente: solo inserta si la tabla esta vacia.
IF NOT EXISTS (SELECT 1 FROM [dbo].[Categories])
BEGIN
    SET IDENTITY_INSERT [dbo].[Categories] ON;
    INSERT INTO [dbo].[Categories] ([CategoryID], [CategoryName], [Description]) VALUES
    (1, N'Beverages', N'Soft drinks, coffees, teas, beers, and ales'),
    (2, N'Condiments', N'Sweet and savory sauces, relishes, spreads, and seasonings'),
    (3, N'Confections', N'Desserts, candies, and sweet breads'),
    (4, N'Dairy Products', N'Cheeses'),
    (5, N'Grains/Cereals', N'Breads, crackers, pasta, and cereal'),
    (6, N'Meat/Poultry', N'Prepared meats'),
    (7, N'Produce', N'Dried fruit and bean curd'),
    (8, N'Seafood', N'Seaweed and fish');
    SET IDENTITY_INSERT [dbo].[Categories] OFF;
END
GO
