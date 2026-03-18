@REQ_PQBP-638 @Agente1
Feature: Consulta jwt

@id:1 @BancaMovil @jwt @test2
  Scenario: T-API-PQBP-638-CA1- Consulta jwt - karate
    * header content-type = 'application/json'
    * def datos = read('classpath:../BancaMovil/datos.csv')
    * def user = read('classpath:../BancaMovil/BMObtenerjwt.json')
    * replace user.dniValue = datos[0].dni
    * replace user.dniTypeValue = datos[0].dniType
    * print user
    Given url 'https://app-security-token-dot-pmovil-app-prod.appspot.com/app/security/token/retrieve/v2'
    And request datos
    When method POST
    Then status 201
    And print response

