/*
Post-Deployment Script (NorthWindOLTP)
--------------------------------------------------------------------------------------
 Carga los datos de ejemplo de Northwind. Cada archivo *.data.sql es idempotente:
 solo inserta cuando la tabla destino esta vacia, de modo que publicar el proyecto
 sobre una base ya cargada NO duplica ni borra informacion.
 Orden: respeta las dependencias de claves foraneas.
 Para vaciar la base (p. ej. en un entorno de pruebas) ejecutar manualmente
 Scripts\clean.data.sql antes de publicar.
--------------------------------------------------------------------------------------
*/
:r .\Region.data.sql
:r .\Territories.data.sql
:r .\Categories.data.sql
:r .\Suppliers.data.sql
:r .\Products.data.sql
:r .\Shippers.data.sql
:r .\Customers.data.sql
:r .\CustomerDemographics.data.sql
:r .\CustomerCustomerDemo.data.sql
:r .\Employees.data.sql
:r .\EmployeeTerritories.data.sql
:r .\Orders.data.sql
:r .\OrderDetails.data.sql
