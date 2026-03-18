@REQ_PQBP-1845 @Database @SqlServer @Agente1
Feature: Prueba con la base de datos
  Background:
    * url baseUrl
    * def ConfigurationParamUtils = Java.type('com.pichincha.utils.ConfigurationParamUtils')
    * def configSqlServer = ConfigurationParamUtils.loadEnviromentalValues('SQLSERVER')
    * def DataBaseUtils = Java.type('com.pichincha.utils.DataBaseUtils')
    * def dbSqlServer = new DataBaseUtils(configSqlServer)

  @id:1 @TraerRegistroDB @ejemplo1
  Scenario: T-PQBP-1845-CA1- Traer un registro de la base SQLSERVER
    * def catalogo = dbSqlServer.readRow('SELECT * FROM testdb.dbo.catalogo where id = 1 ')
    * assert catalogo.nombre == 'parametros query'

  @id:2 @TraerRegistroDB @ejemplo2
  Scenario: T-PQBP-1845-CA1- Traer un registro de la base SQLSERVER 2
    * def value = dbSqlServer.readRow('SELECT mnemonico FROM testdb.dbo.catalogo where id = 2 ')
    * assert value.mnemonico == "param"

  @id:3 @TraerRegistroDB @ejemplo3
  Scenario: T-PQBP-1845-CA1- Traer un registro de la base SQLSERVER 3
    * def rows = dbSqlServer.readRows('SELECT * FROM testdb.dbo.catalogo')
    * print rows

  @id:4 @InsertarRegistroDB @ejemplo1
  Scenario: T-PQBP-1845-CA2- Insertar un registro de la base SQLSERVER
    * def result = dbSqlServer.update('INSERT INTO testdb.dbo.catalogo (id, nombre, mnemonico, valor_cadena, valor_numero) VALUES(?,?,?,?,?)', 8, 'catalogo ocho', 'CATALOGO_8', 'valorcadena8', null)

  @id:5 @EliminarRegistroDB @ejemplo1
  Scenario: T-PQBP-1845-CA3- Eliminar un registro de la base SQLSERVER
    * def result = dbSqlServer.update('DELETE FROM testdb.dbo.catalogo WHERE id=?', 8)

