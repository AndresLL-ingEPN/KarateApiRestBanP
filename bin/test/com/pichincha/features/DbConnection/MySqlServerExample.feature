@REQ_PQBP-1845 @Database @MySql @Agente2
Feature: Creating, modifiying and fetching a user

  Background:
    * def apiKeyValue = '9032237a-7878-4bac-bebb-7151a259eda1'
    * def ConfigurationParamUtils = Java.type('com.pichincha.utils.ConfigurationParamUtils')
    * def configMySql = ConfigurationParamUtils.loadEnviromentalValues('MYSQL')
    * def DataBaseUtils = Java.type('com.pichincha.utils.DataBaseUtils')
    * def dbMySql = new DataBaseUtils(configMySql)

  @id:1 @CreaTabla
  Scenario: T-PQBP-1845-CA1- Crear tabla en la base MYSQL
    * def resultado = dbMySql.update('CREATE TABLE prueba (col1 int NULL, col2 varchar(100) NULL)')
  @id:2 @InsertarRegistro
  Scenario: T-PQBP-1845-CA1-Insertar un registro en la base MYSQL
    * def resultado = dbMySql.update('INSERT INTO prueba (col1, col2) VALUES(?,?)',1,'algo')
  @id:3 @TraerRegistro
  Scenario: T-PQBP-1845-CA1- Traer un registro de la base MYSQL
    * def row = dbMySql.readRow('SELECT * FROM prueba where col1 = 1 ')
    * assert row.col2 == 'algo'

  @id:4 @ReadValue
  Scenario: T-PQBP-1845-CA1- Traer un registro de la base MYSQL 2
    * def value = dbMySql.readValue('SELECT col2 FROM prueba where col1 = 1 ')
    * assert value == 'algo'

  @id:5 @CreateUser
  Scenario: Create User MYSQL
    * def user =
     """
     {
      "id": 779,
      "username": "Test3QA",
      "firstName": "TestingQA",
      "lastName": "TestingQABP",
      "email": "testing@email.com",
      "password": "123456",
      "phone": "0993200468",
      "userStatus": 0
     }
     """
    Given header Content-Type = 'application/javascript'
    And header api_key = apiKeyValue

    Given url baseUrl
    And request user
    When method POST
    Then status 200
    * print response