@REQ_PQBP-639 @Agente2
Feature: Posicion Consolidada

@id:1 @BancaMovil @PosicionConsolidada @test3
  Scenario: T-API-PQBP-639-CA1- Obtener el detalle de la posicion consolidada - karate
    * header content-type = 'application/json'
    * def result = call read('BMLoginBiometrico.feature')
    * def user = read('classpath:../BancaMovil/BMPosicionConsolidada.json')
    * replace user.dniValue = result.response.data.user.dni
    * replace user.sessionValue = result.response.data.headerIn.session
    * replace user.guidValue = result.response.data.headerIn.guid
    Given url 'https://app-transaction-balance-dot-pmovil-app-test.ue.r.appspot.com/app/transaction/balance/v1'
    And request user
    When method POST
    Then status 200
    And print response


