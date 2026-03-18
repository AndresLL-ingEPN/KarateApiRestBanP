@REQ_EVA-002 @APIFakeStore
Feature: Consultar Apis del sistema Fake Store

    ##EVALUACION 23/06/2023 CHAPTER QA
  # 1. Obtener todos los carritos de compra dentro de un rango de fechas tomando como fecha de inicio 2019-12-10 y fecha final la fecha de hoy, validar si dentro de estas fechas se encuentra el carrito con id 5, productId 8 y cantidad 1.
  @id:1 @ConsultarAPIFakeStore @testApi
  Scenario Outline: T-API-EVA-002-CA1- Consulta carritos de compra con fechas
    Given url 'https://fakestoreapi.com/carts?startdate=<inicio>&enddate=<final>'
    When method GET
    Then status 200
    * def carritosArray = response
    * karate.forEach(carritosArray, function(item, index) {if (item.id == <idcarrito>) {karate.set('carritoEncontrado', item)}})
    And carritoEncontrado.id == <idcarrito>
    * print carritoEncontrado
    * def productosArray = carritoEncontrado.products
    * karate.forEach(productosArray, function(product, index) {if (product.productId == <idproducto>) {karate.set('productoEncontrado', product)}})
    And match productoEncontrado.productId == <idproducto>
    And match productoEncontrado.quantity == <cantproducto>
    Examples:
      | inicio     | final      | idcarrito | idproducto | cantproducto |
      | 2019-12-10 | 2023-06-23 | 5         |8           |4             |


    # 2. Actualizar el carrito cuyo identificador sea 6  con los datos userid  33, productoid 25 y cantidad 5.
  @id:2 @PostAPIFakeStore @testApi
  Scenario Outline: T-API-EVA-002-CA2- Update carrito con json
    * def bodyPost = read('classpath:/data/updateCartItem.json')
    Given url 'https://fakestoreapi.com/carts/6'
    When request bodyPost
    And method PUT
    Then status 200
    And match response.userId == <indentificador>
    And match response.products[0].productId == <productoID>
    And match response.products[0].quantity == <cantidad>
    Examples:
      | read('classpath:/data/updateCarItem.csv') |


# 3. Ordenar los carritos de forma ascendente. revisar Codificaci?n de signo ? se va %3F
  @id:3 @ConsultarAPIFakeStore @testApi
  Scenario Outline: T-API-EVA-001-CA1- Consulta carritos forma ascendente
    Given url 'https://fakestoreapi.com/carts?sort=<ordenar>'
    When method GET
    Then status 200
    * print response
    Examples:
      | ordenar |
      | asc     |
