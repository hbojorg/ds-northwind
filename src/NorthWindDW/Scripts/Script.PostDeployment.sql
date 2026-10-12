/*
Post-Deployment Script (NorthWindDW)
--------------------------------------------------------------------------------------
 Datos semilla del almacen (todos idempotentes):
   1. PackageConfig: marcas de agua en 0 para cada paquete.
   2. DimDate: calendario 1996-01-01 .. 2030-12-31.
   3. Miembros "Unknown" (-1) en todas las dimensiones.
 La carga de dimensiones y hechos NO se hace aqui: ejecutar EXEC etl.RunETL.
--------------------------------------------------------------------------------------
*/
:r .\PackageConfig.data.sql
:r .\DimDate.data.sql
:r .\UnknownMembers.data.sql
