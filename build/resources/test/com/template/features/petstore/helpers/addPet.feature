@ignore
Feature: Helper - Añadir Mascota a la Tienda

  # Helper invocado via callonce desde el Background de petstore.feature.
  # Ejecuta POST /pet UNA sola vez y expone el resultado a todos los escenarios:
  #   petId       → id de la mascota creada
  #   petName     → nombre de la mascota
  #   petStatus   → estatus inicial (available)
  #   petResponse → respuesta completa del POST (para que CA1 valide la estructura)
  Scenario: Crear una mascota y retornar su respuesta completa
    * def petBody  = read('classpath:data/petCreate.json')
    * def uniqueId = 900000000 + Math.floor(Math.random() * 99999999)
    * set petBody.id = uniqueId
    Given url 'https://petstore.swagger.io/v2/pet'
    And   request petBody
    When  method POST
    Then  status 200
    * def petId       = response.id
    * def petName     = response.name
    * def petStatus   = response.status
    * def petResponse = response
    * print 'Helper addPet - Mascota creada con ID:', petId
