-- Datos de dbo.Region  (4 filas)  - generado por tools\Export-NorthWindData.ps1
-- Idempotente: solo inserta si la tabla esta vacia.
IF NOT EXISTS (SELECT 1 FROM [dbo].[Region])
BEGIN
    INSERT INTO [dbo].[Region] ([RegionID], [RegionDescription]) VALUES
    (1, N'Eastern                                           '),
    (2, N'Western                                           '),
    (3, N'Northern                                          '),
    (4, N'Southern                                          ');
END
GO
