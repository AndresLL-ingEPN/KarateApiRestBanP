================================================================================
  KarateApiRestBanP — Suite de Pruebas Automatizadas API REST · Petstore
  QA SR Automation
================================================================================

  Proyecto   : Automatización QA — Flujo E2E Petstore API
  Framework  : Karate DSL + JUnit 4 + Gradle
  API Target : https://petstore.swagger.io/v2

================================================================================
  ÍNDICE
================================================================================

  1.  Descripción General
  2.  Stack Tecnológico y Versiones
  3.  Estructura del Proyecto
  4.  Casos de Prueba
  5.  Prerrequisitos
  6.  Instalación y Configuración  (PASOS 1 AL 4)
  7.  Ejecución de Pruebas
  8.  Opciones Avanzadas de Ejecución
  9.  Reportes
  10. Arquitectura de la Solución
  11. Datos de Prueba
  12. Solución de Problemas
  13. Referencia Rápida de Comandos

================================================================================
  1. DESCRIPCIÓN GENERAL
================================================================================

Suite de pruebas automatizadas que valida un flujo E2E completo de gestión de
mascotas sobre la Petstore Swagger API pública (https://petstore.swagger.io/v2).

El flujo cubre:
  - Creación de una mascota            POST /pet
  - Consulta por ID                    GET  /pet/{petId}
  - Actualización de nombre y estatus  PUT  /pet
  - Verificación por estatus           GET  /pet/findByStatus?status=sold
  - Flujo E2E parametrizado DDT        3 iteraciones desde archivo CSV

Patrón callonce en Background: el POST /pet se ejecuta UNA ÚNICA VEZ y
el mismo petId se comparte entre CA1–CA4, garantizando coherencia y evitando
datos huérfanos en la API pública.

================================================================================
  2. STACK TECNOLÓGICO Y VERSIONES
================================================================================

  Tecnología               Versión          Rol
  ─────────────────────────────────────────────────────────────────────────
  Java JDK                 17 (LTS)         Lenguaje base (mínimo JDK 11)
  Gradle                   8.5              Build tool (via Gradle Wrapper)
  Karate DSL               1.3.0            Framework BDD de pruebas API REST
  JUnit                    4.13.2           Test runner subyacente de Karate
  Cucumber Reporting       5.7.0            Reportes HTML (masterthought)
  Lombok Plugin            6.5.1            io.freefair.lombok (boilerplate)
  Jackson Streaming API    incluido Karate  Parseo O(1) stream JSON en CA4
  API Under Test           Petstore v2      https://petstore.swagger.io/v2
  ─────────────────────────────────────────────────────────────────────────

  IMPORTANTE: Se recomienda JDK 17 LTS. NO usar JDK 8 (incompatible con
  Karate 1.x). No es necesario instalar Gradle; el Gradle Wrapper incluido
  en el repositorio descarga Gradle 8.5 automáticamente.

================================================================================
  3. ESTRUCTURA DEL PROYECTO
================================================================================

  KarateApiRestBanP/
  |
  +-- build.gradle                          Dependencias, plugins, config JVM
  +-- gradlew / gradlew.bat                 Gradle Wrapper (Linux/Mac / Windows)
  |
  +-- gradle/wrapper/
  |   +-- gradle-wrapper.properties         Define Gradle 8.5
  |
  +-- src/
  |   +-- main/
  |   |   +-- resources/
  |   |       +-- data/
  |   |           +-- petCreate.json        Payload POST /pet
  |   |           +-- petUpdate.json        Payload PUT  /pet (status=sold)
  |   |           +-- petCA5TestData.csv    Datos DDT CA5 (3 iteraciones)
  |   |
  |   +-- test/
  |       +-- java/
  |           +-- karate-config.js          Config global (env, baseUrlPetstore)
  |           +-- logback-test.xml          Configuración de logging
  |           +-- com/template/
  |               +-- TestRunner.java       Runner JUnit — entrada de la suite
  |               +-- helpers/
  |               |   +-- PetStoreSoldHelper.java  Jackson Streaming API
  |               +-- features/
  |                   +-- petstore/
  |                       +-- petstore.feature     Feature principal (CA1-CA5)
  |                       +-- helpers/
  |                           +-- addPet.feature   Helper callonce POST /pet
  |
  +-- build/                                Generado automáticamente
      +-- karate-reports/
      |   +-- karate-summary.html           Reporte nativo Karate
      +-- cucumber-html-reports/
          +-- overview-features.html        Reporte Cucumber enriquecido

================================================================================
  4. CASOS DE PRUEBA
================================================================================

  ID    Escenario                                  Método    Endpoint
  ────────────────────────────────────────────────────────────────────────────
  CA1   Añadir una nueva mascota a la tienda       POST      /pet
  CA2   Consultar la mascota ingresada por ID      GET       /pet/{petId}
  CA3   Actualizar nombre y estatus a "sold"       PUT       /pet
  CA4   Confirmar mascota por estatus (Streaming)  GET       /pet/findByStatus
  CA5   E2E parametrizado DDT (3 filas CSV)        POST/GET  Flujo completo
        /PUT/GET
  ────────────────────────────────────────────────────────────────────────────

  Tags disponibles:
    @APIPetstore              Toda la feature Petstore
    @SmokeTest                CA1, CA2, CA3, CA4, CA5
    @REQ_EVA-BP               Requerimiento de negocio
    @AgregarMascota           CA1
    @ConsultarMascotaPorId    CA2
    @ActualizarMascota        CA3
    @ConsultarMascotaPorEstado CA4
    @DataDriven               CA5
    @id:1 ... @id:5           Por ID de escenario específico

  NOTA CA4/CA5-d: /findByStatus retorna miles de objetos. PetStoreSoldHelper
  usa Jackson Streaming API para buscar el petId sin cargar el array completo
  en memoria (O(1) heap), previniendo OutOfMemoryError.

================================================================================
  5. PRERREQUISITOS
================================================================================

  [ ] Java JDK 17 LTS instalado y configurado en JAVA_HOME
  [ ] Conexión a internet activa (se consume la API pública de Petstore)
  [ ] Git instalado (opcional, solo para clonar el repositorio)
  [ ] NO se requiere instalar Gradle manualmente (incluye Gradle Wrapper)

  --- Verificar Java ---

  Ejecutar en terminal:
    java -version

  Salida esperada:
    openjdk version "17.x.x" ...

  --- Descargar JDK 17 (si no está instalado) ---

  Adoptium Temurin 17 (recomendado):
    https://adoptium.net/temurin/releases/?version=17

  Oracle JDK 17:
    https://www.oracle.com/java/technologies/downloads/#java17

  --- Configurar JAVA_HOME en Windows (PowerShell como Administrador) ---

    [System.Environment]::SetEnvironmentVariable(
      "JAVA_HOME",
      "C:\Program Files\Java\jdk-17",
      "Machine"
    )
    $env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH

  --- Configurar JAVA_HOME en Linux / macOS ---

    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
    export PATH=$JAVA_HOME/bin:$PATH
    # Agregar al ~/.bashrc o ~/.zshrc para persistencia

================================================================================
  6. INSTALACIÓN Y CONFIGURACIÓN — PASOS 1 AL 4
================================================================================

  ─── PASO 1: Obtener el proyecto ─────────────────────────────────────────────

  Opción A — Clonar con Git:

    git clone <URL_DEL_REPOSITORIO>
    cd KarateApiRestBanP

  Opción B — Descomprimir ZIP:

    Descomprimir el archivo ZIP descargado y luego:
    cd KarateApiRestBanP

  ─── PASO 2: Verificar permisos del Gradle Wrapper ───────────────────────────

  Linux / macOS:
    chmod +x gradlew

  Windows:
    No requiere configuración adicional. Usar gradlew.bat

  ─── PASO 3: Descargar dependencias ──────────────────────────────────────────

  Windows:
    .\gradlew.bat dependencies

  Linux / macOS:
    ./gradlew dependencies

  La primera ejecución descarga Gradle 8.5 y las dependencias del proyecto
  a ~/.gradle/caches/. Puede tardar 2-5 minutos según la velocidad de red.

  ─── PASO 4: Verificar la configuración ──────────────────────────────────────

  Windows:
    .\gradlew.bat --version

  Linux / macOS:
    ./gradlew --version

  Salida esperada:
    Gradle 8.5
    JVM: 17.x.x (...)

================================================================================
  7. EJECUCIÓN DE PRUEBAS
================================================================================

  --- Ejecución completa (todos los escenarios CA1-CA5) ---

  Windows:
    .\gradlew.bat clean test

  Linux / macOS:
    ./gradlew clean test

  --- Ejecución con generación completa de reportes ---

  Windows:
    .\gradlew.bat clean test aggregate

  Linux / macOS:
    ./gradlew clean test aggregate

  RECOMENDACIÓN: Usar siempre "clean test" para garantizar un estado de
  build limpio. El flag outputs.upToDateWhen { false } en build.gradle ya
  fuerza la re-ejecución, pero "clean" elimina artefactos previos.

================================================================================
  8. OPCIONES AVANZADAS DE EJECUCIÓN
================================================================================

  --- Por Tag ---

  # Feature Petstore completa
  .\gradlew.bat clean test -Dkarate.options="--tags @APIPetstore"

  # Solo Smoke Tests
  .\gradlew.bat clean test -Dkarate.options="--tags @SmokeTest"

  # Solo CA5 Data Driven
  .\gradlew.bat clean test -Dkarate.options="--tags @DataDriven"

  # Solo CA4 Streaming
  .\gradlew.bat clean test -Dkarate.options="--tags @ConsultarMascotaPorEstado"

  # Excluir DDT (todo menos CA5)
  .\gradlew.bat clean test -Dkarate.options="--tags ~@DataDriven"

  # Combinar tags (AND)
  .\gradlew.bat clean test -Dkarate.options="--tags @APIPetstore,@SmokeTest"

  --- Por ID de escenario ---

  # Solo CA1
  .\gradlew.bat clean test -Dkarate.options="--tags @id:1"

  # CA2 y CA3
  .\gradlew.bat clean test -Dkarate.options="--tags @id:2,@id:3"

  --- Por entorno ---

  # Entorno dev (por defecto si no se especifica)
  .\gradlew.bat clean test -Dkarate.env=dev

  Los entornos se configuran en src/test/java/karate-config.js.
  Para nuevos entornos (staging, prod), agregar condiciones if (env == '...')
  en dicho archivo.

  --- Configuración JVM (definida en build.gradle) ---

  Actual:
    jvmArgs '-Xmx512m', '-Xms128m', '-XX:+UseG1GC'

  Para suites más grandes (modificar build.gradle):
    jvmArgs '-Xmx1g', '-Xms256m', '-XX:+UseG1GC'

================================================================================
  9. REPORTES
================================================================================

  Reporte                Ruta                                          Descripción
  ──────────────────────────────────────────────────────────────────────────────
  Karate Summary         build/karate-reports/karate-summary.html     Resumen general
  Karate Tags            build/karate-reports/karate-tags.html        Por tag
  Karate Timeline        build/karate-reports/karate-timeline.html    Línea de tiempo
  Karate Log             build/karate-reports/karate.log              Log completo
  Cucumber Overview      build/cucumber-html-reports/overview-features.html
  Cucumber Steps         build/cucumber-html-reports/overview-steps.html
  Cucumber Tags          build/cucumber-html-reports/overview-tags.html
  Cucumber Failures      build/cucumber-html-reports/overview-failures.html
  ──────────────────────────────────────────────────────────────────────────────

  --- Abrir reportes en Windows ---

  # Reporte Karate
  Start-Process "build\karate-reports\karate-summary.html"

  # Reporte Cucumber
  Start-Process "build\cucumber-html-reports\overview-features.html"

  # Ver últimas 50 líneas del log
  Get-Content "build\karate-reports\karate.log" -Tail 50

================================================================================
  10. ARQUITECTURA DE LA SOLUCIÓN
================================================================================

  TestRunner.java
  (JUnit 4 · @APIPetstore · parallel(1))
        |
        v
  petstore.feature
  |
  +-- Background
  |   +-- callonce --> addPet.feature --> POST /pet
  |                    (petId, petName compartidos CA1-CA4)
  |
  +-- CA1  POST /pet   · Validar estructura y datos     @AgregarMascota
  +-- CA2  GET  /pet/{petId}                            @ConsultarMascotaPorId
  +-- CA3  PUT  /pet --> status=sold                    @ActualizarMascota
  +-- CA4  GET  /findByStatus                           @ConsultarMascotaPorEstado
  |        |
  |        +--> PetStoreSoldHelper.java
  |             · HttpURLConnection
  |             · Jackson Streaming Parser (O(1) heap)
  |             · Retorna Map a Karate
  |
  +-- CA5  Scenario Outline DDT (3 filas CSV)           @DataDriven
           Flujo a/b/c/d = CA1 + CA2 + CA3 + CA4 por fila
           Cada fila usa su propio pet con ID dinamico

  Decisiones de diseño:
  ┌─────────────────────────────┬──────────────────────────────────────────────┐
  │ Decisión                    │ Justificación                                │
  ├─────────────────────────────┼──────────────────────────────────────────────┤
  │ callonce en Background      │ Un solo POST /pet — datos consistentes CA1-4 │
  │ Jackson Streaming API       │ /findByStatus devuelve miles de objetos, OOM │
  │ parallel(1)                 │ API pública sensible a condiciones de carrera │
  │ IDs dinámicos (random)      │ Evita colisiones con datos de otros usuarios  │
  │ CSV para DDT (CA5)          │ Separación de datos y lógica de test         │
  └─────────────────────────────┴──────────────────────────────────────────────┘

================================================================================
  11. DATOS DE PRUEBA
================================================================================

  --- petCreate.json (src/main/resources/data/) ---

  {
    "id": 9981234567,            <- sobreescrito con ID dinamico en runtime
    "category": { "id": 1, "name": "Perros" },
    "name": "Firulais",
    "photoUrls": ["https://example.com/photos/firulais.jpg"],
    "tags": [{ "id": 1, "name": "jugueton" }],
    "status": "available"
  }

  ID dinamico: 900000000 + Math.floor(Math.random() * 99999999)

  --- petUpdate.json (src/main/resources/data/) ---

  {
    "id": 0,                     <- reemplazado con petId real del Background
    "category": { "id": 1, "name": "Perros" },
    "name": "FirulaisActualizado",
    "photoUrls": ["https://example.com/photos/firulais-updated.jpg"],
    "tags": [{ "id": 1, "name": "jugueton" }],
    "status": "sold"
  }

  --- petCA5TestData.csv (src/main/resources/data/) ---

  petName,categoryName,tagName,updatedName
  Kira,Gatos,tranquilo,KiraActualizada
  Rex,Perros,activo,RexActualizado
  Luna,Aves,curioso,LunaActualizada

  Genera 3 ejecuciones independientes del flujo E2E completo.
  Cada fila crea su propio pet con ID unico generado dinamicamente.

================================================================================
  12. SOLUCIÓN DE PROBLEMAS
================================================================================

  PROBLEMA: JAVA_HOME no esta definida / JDK no encontrado
  ─────────────────────────────────────────────────────────
  # Verificar
  $env:JAVA_HOME

  # Configurar temporalmente (PowerShell)
  $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
  $env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH
  java -version

  ──────────────────────────────────────────────────────────

  PROBLEMA: OutOfMemoryError: Java heap space
  ─────────────────────────────────────────────────────────
  Ya mitigado con Jackson Streaming API en CA4/CA5-d.
  Si persiste, en build.gradle cambiar:
    jvmArgs '-Xmx1g', '-Xms256m', '-XX:+UseG1GC'

  ──────────────────────────────────────────────────────────

  PROBLEMA: Connection refused / SocketTimeoutException
  ─────────────────────────────────────────────────────────
  1. Verificar conectividad a internet
  2. Aumentar timeouts en PetStoreSoldHelper.java:
       conn.setConnectTimeout(60_000);
       conn.setReadTimeout(180_000);

  ──────────────────────────────────────────────────────────

  PROBLEMA: gradlew.bat no se ejecuta / no reconocido
  ─────────────────────────────────────────────────────────
  # Navegar a la raiz del proyecto y ejecutar
  Set-Location "C:\Users\allumiqu\Documents\KarateApiRestBanP"
  .\gradlew.bat --version

  ──────────────────────────────────────────────────────────

  PROBLEMA: Status 404 en CA2 o CA3
  ─────────────────────────────────────────────────────────
  La API Petstore es publica y compartida; puede limpiar datos periodicamente.
  El callonce garantiza petId fresco en cada ejecucion. Si persiste, puede
  ser latencia de propagacion — reejecutar la suite completa.

  ──────────────────────────────────────────────────────────

  PROBLEMA: Reportes no se generan / vacios
  ─────────────────────────────────────────────────────────
  Usar siempre clean test:
    .\gradlew.bat clean test

================================================================================
  13. REFERENCIA RÁPIDA DE COMANDOS
================================================================================

  EJECUCION
  ─────────────────────────────────────────────────────────────────────────────

  Suite completa:
    .\gradlew.bat clean test

  Suite completa + reportes:
    .\gradlew.bat clean test aggregate

  Solo SmokeTest:
    .\gradlew.bat clean test -Dkarate.options="--tags @SmokeTest"

  Feature Petstore:
    .\gradlew.bat clean test -Dkarate.options="--tags @APIPetstore"

  Solo CA5 DDT:
    .\gradlew.bat clean test -Dkarate.options="--tags @DataDriven"

  Solo CA4 Streaming:
    .\gradlew.bat clean test -Dkarate.options="--tags @ConsultarMascotaPorEstado"

  Excluir DDT:
    .\gradlew.bat clean test -Dkarate.options="--tags ~@DataDriven"

  Por ID de escenario (ej. CA1):
    .\gradlew.bat clean test -Dkarate.options="--tags @id:1"

  Con entorno:
    .\gradlew.bat clean test -Dkarate.env=dev

  BUILD / UTILIDADES
  ─────────────────────────────────────────────────────────────────────────────

  Ver dependencias:
    .\gradlew.bat dependencies

  Debug Karate CLI:
    .\gradlew.bat karateDebug

  Solo compilar:
    .\gradlew.bat compileTestJava

  Version de Gradle:
    .\gradlew.bat --version

  REPORTES
  ─────────────────────────────────────────────────────────────────────────────

  Abrir reporte Karate:
    Start-Process "build\karate-reports\karate-summary.html"

  Abrir reporte Cucumber:
    Start-Process "build\cucumber-html-reports\overview-features.html"

  Ver log de ejecucion (ultimas 50 lineas):
    Get-Content "build\karate-reports\karate.log" -Tail 50

================================================================================
  Documentacion tecnica — KarateApiRestBanP · QA SR Automation
================================================================================

