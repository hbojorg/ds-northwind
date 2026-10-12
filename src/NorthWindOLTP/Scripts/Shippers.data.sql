-- Datos de dbo.Shippers  (3 filas)  - generado por tools\Export-NorthWindData.ps1
-- Idempotente: solo inserta si la tabla esta vacia.
IF NOT EXISTS (SELECT 1 FROM [dbo].[Shippers])
BEGIN
    SET IDENTITY_INSERT [dbo].[Shippers] ON;
    INSERT INTO [dbo].[Shippers] ([ShipperID], [CompanyName], [Phone]) VALUES
    (1, N'Speedy Express', N'(503) 555-9831'),
    (2, N'United Package', N'(503) 555-3199'),
    (3, N'Federal Shipping', N'(503) 555-9931');
    SET IDENTITY_INSERT [dbo].[Shippers] OFF;
END
GO
