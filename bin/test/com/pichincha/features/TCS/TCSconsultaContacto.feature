@REQ_PQBP-640 @TCS @Agente2
Feature: Consulta servicio WSClientes0007

  @id:1 @consulta @consultaValida
  Scenario: T-API-PQBP-640-CA1- Consulta contacto transaccional WSClientes0007 - karate
    * header authorization = 'Basic YmpqYXJhOnBpY2hpbmNoYTE='
    * header content-type = 'application/json'
    Given url 'https://api-test.pichincha.com/tcs/WSClientes0007'
    And def user = read('classpath:../TCS/consultaContactoTransaccionalData.json')
    And request user
    When method POST
    Then status 200
    And print response
    And match response.ConsultarContactoTransaccional01Response.error.mensajeNegocio contains 'Transaccion exitosa.'

  @id:2 @consulta @consultaFallida
  Scenario: T-API-PQBP-640-CA2- Consulta contacto transaccional WSClientes0007 fallido - karate 
    * header authorization = 'Basic YmpqYXJhOnBpY2hpbmNoYTE='
    * header content-type = 'application/json'
    Given url 'https://api-test.pichincha.com/tcs/WSClientes0007'
    And def user = read('classpath:../TCS/consultaContactoTransaccionalData.json')
    And request user
    When method POST
    Then status 401
    And print response
    And match response.ConsultarContactoTransaccional01Response.error.mensajeNegocio contains 'Error'
