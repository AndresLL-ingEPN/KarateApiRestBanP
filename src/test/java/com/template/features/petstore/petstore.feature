@REQ_EVA-BP @APIPetstore
Feature: Gestión de Mascotas - Petstore API

  # Flujo E2E sobre UN ÚNICO pet compartido entre los 4 casos:
  #
  #   CA1 - POST /pet              → Crear mascota  (el callonce del Background ejecuta el POST;
  #                                                   CA1 valida la respuesta de esa creación)
  #   CA2 - GET  /pet/{petId}      → Consultar la mascota creada en CA1 por ID
  #   CA3 - PUT  /pet              → Actualizar nombre y estatus a "sold" de la mascota de CA1
  #   CA4 - GET  /pet/findByStatus → Confirmar que la mascota de CA3 aparece filtrada por estatus
  #
  # El callonce garantiza que el POST se ejecuta una sola vez y petId es el mismo en CA1-CA4.

  Background:
    * def baseUrlPetstore = 'https://petstore.swagger.io/v2'
    * def petSetup        = callonce read('classpath:com/template/features/petstore/helpers/addPet.feature')
    * def petId           = petSetup.petId
    * def petName         = petSetup.petName


  # ─────────────────────────────────────────────────────────────────────────────
  @id:1 @AgregarMascota @APIPetstore
  Scenario: T-API-PS-CA1 - Añadir una nueva mascota a la tienda

    # El Background ejecutó POST /pet via callonce y expuso petSetup.petResponse.
    # Este escenario valida que la respuesta del POST cumple la estructura y los datos esperados.
    * def created = petSetup.petResponse

    Then  match created.id       == '#number'
    And   match created.name     == petName
    And   match created.status   == 'available'
    And   match created.category contains { id: '#number', name: '#string' }
    And   match created.photoUrls == '#[] #string'
    * match each created.tags == { id: '#number', name: '#string' }
    * print 'CA1 ✔ | POST /pet | ID:', petId, '| Nombre:', petName, '| Estatus:', created.status


  # ─────────────────────────────────────────────────────────────────────────────
  @id:2 @ConsultarMascotaPorId @APIPetstore
  Scenario: T-API-PS-CA2 - Consultar la mascota ingresada previamente por ID

    # Busca exactamente el pet creado en CA1 (mismo petId del callonce)
    Given url baseUrlPetstore + '/pet/' + petId
    When  method GET
    Then  status 200

    And   match response.id     == petId
    And   match response.name   == petName
    And   match response.status == 'available'
    And   match response contains { id: '#number', name: '#string', status: '#string' }
    * print 'CA2 ✔ | GET /pet/{id} | ID:', response.id, '| Nombre:', response.name, '| Estatus:', response.status


  # ─────────────────────────────────────────────────────────────────────────────
  @id:3 @ActualizarMascota @APIPetstore
  Scenario: T-API-PS-CA3 - Actualizar nombre y estatus de la mascota a "sold"

    # Actualiza el mismo pet de CA1/CA2 usando su petId
    * def petUpdateBody    = read('classpath:data/petUpdate.json')
    * set petUpdateBody.id = petId
    Given url baseUrlPetstore + '/pet'
    And   request petUpdateBody
    When  method PUT
    Then  status 200

    And   match response.id     == petId
    And   match response.name   == 'FirulaisActualizado'
    And   match response.status == 'sold'
    * print 'CA3 ✔ | PUT /pet | ID:', response.id, '| Nombre:', response.name, '| Estatus:', response.status


  # ─────────────────────────────────────────────────────────────────────────────
  @id:4 @ConsultarMascotaPorEstado @APIPetstore
  Scenario: T-API-PS-CA4 - Confirmar que la mascota modificada aparece en la búsqueda por estatus "sold"

    # El endpoint retorna miles de registros → cargar el array completo provoca OOM.
    # PetStoreSoldHelper usa Jackson Streaming API para buscar nuestro petId específico
    # sin materializar el array completo en memoria (consumo O(1) de heap).
    * def PetStoreSoldHelper = Java.type('com.template.helpers.PetStoreSoldHelper')
    * print 'CA4 | Buscando petId', petId, 'en GET /pet/findByStatus?status=sold via Streaming'

    Given def foundPet = PetStoreSoldHelper.findPetByIdInSoldStream(petId)

    Then  assert foundPet.httpStatus == 200
    And   match foundPet.id     == petId
    And   match foundPet.status == 'sold'
    And   match foundPet.name   == 'FirulaisActualizado'
    And   match foundPet contains { id: '#number', status: '#string' }

    * print '══════════════════════════════════════════════════════'
    * print 'CA4 ✔ | La mascota modificada fue encontrada por estatus'
    * print 'Endpoint :', foundPet.endpoint
    * print 'HTTP     :', foundPet.httpStatus
    * print 'ID       :', foundPet.id
    * print 'Nombre   :', foundPet.name
    * print 'Estatus  :', foundPet.status
    * print 'Técnica  :', foundPet.strategy
    * print '══════════════════════════════════════════════════════'
