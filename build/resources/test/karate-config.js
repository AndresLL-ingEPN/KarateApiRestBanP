function() {
  var env = karate.env || 'dev';

  var config = {
    env:             env,
    baseUrlPetstore: 'https://petstore.swagger.io/v2'
  };

  return config;
}
