@REQ_PQBP-637 @Agente2
Feature: Login biometrico

@id:1 @BancaMovil @LoginBiometrico @ignore
  Scenario: T-API-PQBP-637-CA1- Login biometrico - karate
    * header content-type = 'application/json'
    Given url 'https://app-security-login-biometric-dot-pmovil-app-test.appspot.com/app/security/login/biometric/v2'
    And def user = read('classpath:../BancaMovil/BMloginBiometrico.json')
    And request user
    When method POST
    Then status 200
    And print response

