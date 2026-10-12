-- Marcas de agua iniciales (0 = cargar todo el origen en la primera corrida)
MERGE [etl].[PackageConfig] AS t
USING (VALUES ('DimCustomer'), ('DimEmployee'), ('DimProduct'), ('DimShipper'), ('FactSales')) AS s (PackageName)
   ON t.PackageName = s.PackageName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (PackageName, LastRowVersion) VALUES (s.PackageName, 0);
GO
