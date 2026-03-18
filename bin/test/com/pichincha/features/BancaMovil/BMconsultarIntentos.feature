@REQ_PQBP-636 @Agente1
Feature: Consulta Intentos

@id:1 @BancaMovil @intentos
  Scenario: T-API-PQBP-636-CA1- Consulta Intentos - karate
    * header content-type = 'application/json'
    Given url 'https://app-security-username-attempts-dot-pmovil-app-test.ue.r.appspot.com/app/security/biometric/identification/attempts/v7'
    And def user = read('classpath:../BancaMovil/BMconsultaIntentosUsuarioData.json')
    And request user
    When method POST
    Then status 201
    And print response


