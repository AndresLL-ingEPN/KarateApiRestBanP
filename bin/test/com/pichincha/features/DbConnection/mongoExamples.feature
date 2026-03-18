@REQ_PQBP-1846 @Database @Mongo @Agente1
Feature: Prueba con la base de datos
  Background:
    * def ConfigurationParamUtils = Java.type('com.pichincha.utils.ConfigurationParamUtils')
    * def Catalogo = Java.type('com.pichincha.documents.model.Catalogo')
    * def configMongo = ConfigurationParamUtils.loadEnviromentalValues('MONGO')
    * def MongoUtils = Java.type('com.pichincha.utils.MongoUtils')
    * def mongoClient = new MongoUtils(configMongo)

  @id:1 @TraerCollection
  Scenario: T-PQBP-1846-CA1- Traer una collection de la base Mongo
    * def resultado = mongoClient.getCollection('catalogo', Catalogo.class)
    * print resultado