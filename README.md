# 🐾 KarateApiRestBanP — Suite de Pruebas Automatizadas API REST · Petstore

> **Proyecto:** Automatización QA — Flujo E2E Petstore API  
> **Framework:** Karate DSL + JUnit 4 + Gradle  
> **Elaborado por:** QA SR Automation  
> **API Under Test:** [Petstore Swagger v2](https://petstore.swagger.io/v2)

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Stack Tecnológico y Versiones](#stack-tecnológico-y-versiones)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Casos de Prueba](#casos-de-prueba)
5. [Prerrequisitos](#prerrequisitos)
6. [Instalación y Configuración](#instalación-y-configuración)
7. [Ejecución de Pruebas](#ejecución-de-pruebas)
8. [Opciones Avanzadas de Ejecución](#opciones-avanzadas-de-ejecución)
9. [Reportes](#reportes)
10. [Arquitectura de la Solución](#arquitectura-de-la-solución)
11. [Datos de Prueba](#datos-de-prueba)
12. [Solución de Problemas](#solución-de-problemas)
13. [Referencia Rápida de Comandos](#referencia-rápida-de-comandos)

---

## 📝 Descripción General

Suite de pruebas automatizadas de API REST sobre la **Petstore Swagger API pública** (`https://petstore.swagger.io/v2`). Valida un flujo E2E completo de gestión de mascotas que comprende:

- Creación de una mascota (**POST /pet**)
- Consulta por ID (**GET /pet/{petId}**)
- Actualización de nombre y estatus (**PUT /pet**)
- Verificación por estatus con **Jackson Streaming API** — consumo O(1) de heap (**GET /pet/findByStatus**)
- Flujo E2E completo parametrizado con **Data Driven Testing** (3 iteraciones desde CSV)

El patrón `callonce` del `Background` garantiza que el `POST /pet` se ejecuta **una única vez**, compartiendo el mismo `petId` entre los escenarios CA1–CA4 y evitando datos huérfanos en la API pública.

---

## ⚙️ Stack Tecnológico y Versiones

| Tecnología               | Versión              | Rol en el Proyecto                                           |
|--------------------------|----------------------|--------------------------------------------------------------|
| **Java JDK**             | **17** (LTS)         | Lenguaje base; Karate 1.3.0 requiere mínimo JDK 11           |
| **Gradle**               | **8.5**              | Build tool (gestionado por Gradle Wrapper incluido en repo)  |
| **Karate DSL**           | **1.3.0**            | Framework BDD de pruebas API REST (`karate-junit4`)          |
| **JUnit**                | **4.13.2**           | Test runner subyacente requerido por Karate                  |
| **Cucumber Reporting**   | **5.7.0**            | Generación de reportes HTML enriquecidos (`masterthought`)   |
| **Lombok**               | Plugin **6.5.1**     | Plugin Gradle `io.freefair.lombok` — reduce boilerplate Java |
| **Jackson Streaming API**| Incluido en Karate   | Parseo O(1) del stream JSON en CA4 (evita OOM)               |
| **API Under Test**       | Petstore Swagger v2  | `https://petstore.swagger.io/v2`                             |

> ⚠️ **Compatibilidad:** Se recomienda **JDK 17 LTS**. No usar JDK 8 (no compatible con Karate 1.x).

---

## 🗂️ Estructura del Proyecto

```
KarateApiRestBanP/
│
├── build.gradle                            # Dependencias, plugins y configuración JVM
├── gradlew / gradlew.bat                   # Gradle Wrapper (Linux·macOS / Windows)
│
├── gradle/wrapper/
│   └── gradle-wrapper.properties          # Define Gradle 8.5
│
├── src/
│   ├── main/
│   │   └── resources/
│   │       └── data/
│   │           ├── petCreate.json          # Payload POST /pet (creación de mascota)
│   │           ├── petUpdate.json          # Payload PUT  /pet (actualiza → status: sold)
│   │           └── petCA5TestData.csv      # Datos DDT para CA5 (3 iteraciones)
│   │
│   └── test/
│       └── java/
│           ├── karate-config.js            # Config global Karate (env, baseUrlPetstore)
│           ├── logback-test.xml            # Configuración de logging (nivel Karate)
│           └── com/template/
│               ├── TestRunner.java         # Runner JUnit — punto de entrada de la suite
│               ├── helpers/
│               │   └── PetStoreSoldHelper.java  # Helper Java — Jackson Streaming API
│               └── features/
│                   └── petstore/
│                       ├── petstore.feature      # Feature principal (CA1–CA5)
│                       └── helpers/
│                           └── addPet.feature    # Helper callonce — POST /pet
│
└── build/                                  # Generado automáticamente por Gradle
    ├── karate-reports/                     # Reporte nativo Karate
    │   └── karate-summary.html
    └── cucumber-html-reports/              # Reporte Cucumber enriquecido
        └── overview-features.html
```

---

## 🧪 Casos de Prueba

| ID      | Escenario                                          | Método HTTP        | Endpoint                          | Tags                                    |
|---------|----------------------------------------------------|--------------------|-----------------------------------|-----------------------------------------|
| **CA1** | Añadir una nueva mascota a la tienda               | `POST`             | `/pet`                            | `@AgregarMascota` `@SmokeTest`          |
| **CA2** | Consultar la mascota ingresada por ID              | `GET`              | `/pet/{petId}`                    | `@ConsultarMascotaPorId` `@SmokeTest`   |
| **CA3** | Actualizar nombre y estatus a `"sold"`             | `PUT`              | `/pet`                            | `@ActualizarMascota` `@SmokeTest`       |
| **CA4** | Confirmar mascota por estatus "sold" (Streaming)   | `GET`              | `/pet/findByStatus?status=sold`   | `@ConsultarMascotaPorEstado` `@SmokeTest` |
| **CA5** | E2E parametrizado DDT — 3 iteraciones desde CSV    | `POST/GET/PUT/GET` | Flujo completo                    | `@DataDriven` `@SmokeTest`              |

> **Nota técnica CA4/CA5-d:** El endpoint `/findByStatus` retorna miles de registros. Se usa `PetStoreSoldHelper` con **Jackson Streaming API** para buscar el `petId` específico sin materializar el array completo en memoria (consumo **O(1) de heap**), previniendo `OutOfMemoryError`.

---

## ✅ Prerrequisitos

### 1. Java JDK 17

**Verificar instalación:**
```bash
java -version
# Salida esperada: openjdk version "17.x.x" 2021-09-14
```

**Descargar JDK 17 LTS:**
- [Adoptium Temurin 17](https://adoptium.net/temurin/releases/?version=17) ✅ Recomendado
- [Oracle JDK 17](https://www.oracle.com/java/technologies/downloads/#java17)

**Configurar `JAVA_HOME` en Windows (PowerShell como Administrador):**
```powershell
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "Machine")
$env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH
```

**Configurar `JAVA_HOME` en Linux / macOS:**
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH
# Agregar al ~/.bashrc o ~/.zshrc para persistencia
```

### 2. Conexión a Internet

La suite consume la API pública `https://petstore.swagger.io`. Se requiere conectividad activa durante la ejecución.

### 3. Git (opcional — para clonar el repositorio)

```bash
git --version
# Salida esperada: git version 2.x.x
```

> **No se requiere** instalar Gradle manualmente. El repositorio incluye **Gradle Wrapper** (`gradlew.bat` / `gradlew`) que descarga Gradle 8.5 automáticamente.

---

## 🚀 Instalación y Configuración

### Paso 1 — Obtener el proyecto

```bash
# Clonar con Git
git clone <URL_DEL_REPOSITORIO>
cd KarateApiRestBanP

# O descomprimir el ZIP descargado y acceder a la carpeta
cd KarateApiRestBanP
```

### Paso 2 — Verificar permisos del Gradle Wrapper

**Linux / macOS:**
```bash
chmod +x gradlew
```
**Windows:** No requiere configuración adicional. Usar `gradlew.bat`.

### Paso 3 — Descargar dependencias

```powershell
# Windows
.\gradlew.bat dependencies
```
```bash
# Linux / macOS
./gradlew dependencies
```

> La primera ejecución descarga **Gradle 8.5** y las dependencias del proyecto a `~/.gradle/caches/`. Puede tardar **2–5 minutos** según la velocidad de red.

### Paso 4 — Verificar la configuración

```powershell
# Verificar versión de Gradle
.\gradlew.bat --version

# Salida esperada:
# Gradle 8.5
# JVM: 17.x.x (...)
```

---

## ▶️ Ejecución de Pruebas

### Ejecución completa (todos los escenarios CA1–CA5)

```powershell
# Windows
.\gradlew.bat clean test
```
```bash
# Linux / macOS
./gradlew clean test
```

### Ejecución con generación de reportes

```powershell
# Windows
.\gradlew.bat clean test aggregate
```
```bash
# Linux / macOS
./gradlew clean test aggregate
```

> El flag `clean` elimina builds previos. La opción `outputs.upToDateWhen { false }` en `build.gradle` ya fuerza la re-ejecución, pero se recomienda siempre usar `clean` para garantizar un estado limpio.

---

## 🔧 Opciones Avanzadas de Ejecución

### Ejecutar por Tag

```powershell
# Feature completa Petstore
.\gradlew.bat clean test -Dkarate.options="--tags @APIPetstore"

# Solo Smoke Tests
.\gradlew.bat clean test -Dkarate.options="--tags @SmokeTest"

# Solo CA5 Data Driven Testing
.\gradlew.bat clean test -Dkarate.options="--tags @DataDriven"

# Solo CA4 (Consulta por estatus con Streaming)
.\gradlew.bat clean test -Dkarate.options="--tags @ConsultarMascotaPorEstado"

# Excluir un tag (ejecutar todo excepto DDT)
.\gradlew.bat clean test -Dkarate.options="--tags ~@DataDriven"

# Combinar tags (AND)
.\gradlew.bat clean test -Dkarate.options="--tags @APIPetstore,@SmokeTest"
```

### Ejecutar por ID de escenario

```powershell
# Solo CA1
.\gradlew.bat clean test -Dkarate.options="--tags @id:1"

# CA2 y CA3
.\gradlew.bat clean test -Dkarate.options="--tags @id:2,@id:3"
```

### Seleccionar entorno de ejecución

```powershell
# Entorno dev (por defecto si no se especifica)
.\gradlew.bat clean test -Dkarate.env=dev
```

> Los entornos se configuran en `src/test/java/karate-config.js`. Para agregar nuevos entornos (staging, prod), añadir condiciones `if (env == 'staging') { ... }` en dicho archivo.

### Configuración JVM (ya definida en build.gradle)

```groovy
jvmArgs '-Xmx512m', '-Xms128m', '-XX:+UseG1GC'
```

Para suites más grandes, ajustar en `build.gradle`:
```groovy
jvmArgs '-Xmx1g', '-Xms256m', '-XX:+UseG1GC'
```

---

## 📊 Reportes

Tras cada ejecución exitosa, los reportes se generan automáticamente:

| Reporte                  | Ruta                                                      | Descripción                               |
|--------------------------|-----------------------------------------------------------|-------------------------------------------|
| **Karate Summary**       | `build/karate-reports/karate-summary.html`                | Resumen general con métricas y estado     |
| **Karate Tags**          | `build/karate-reports/karate-tags.html`                   | Resultados agrupados por tag              |
| **Karate Timeline**      | `build/karate-reports/karate-timeline.html`               | Línea de tiempo de ejecución de escenarios|
| **Karate Log**           | `build/karate-reports/karate.log`                         | Log completo con detalle de requests/resp.|
| **Cucumber Overview**    | `build/cucumber-html-reports/overview-features.html`      | Vista general enriquecida por features    |
| **Cucumber Steps**       | `build/cucumber-html-reports/overview-steps.html`         | Detalle de todos los pasos ejecutados     |
| **Cucumber Tags**        | `build/cucumber-html-reports/overview-tags.html`          | Resumen por tags con métricas             |
| **Cucumber Failures**    | `build/cucumber-html-reports/overview-failures.html`      | Detalle de escenarios fallidos            |

### Abrir reportes en Windows

```powershell
# Reporte Karate (nativo)
Start-Process "build\karate-reports\karate-summary.html"

# Reporte Cucumber (enriquecido)
Start-Process "build\cucumber-html-reports\overview-features.html"
```

---

## 🏗️ Arquitectura de la Solución

```
┌──────────────────────────────────────────────────────────────────┐
│                       TestRunner.java                            │
│     JUnit 4 · Runner.path("petstore") · @APIPetstore · par(1)   │
└─────────────────────────┬────────────────────────────────────────┘
                          │ invoca
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                      petstore.feature                            │
│                                                                  │
│  Background                                                      │
│  └── callonce ──► addPet.feature ──► POST /pet                  │
│                   (petId, petName compartidos CA1–CA4)           │
│                                                                  │
│  CA1 @id:1  Validar respuesta POST /pet    @AgregarMascota       │
│  CA2 @id:2  GET  /pet/{petId}              @ConsultarMascotaPorId│
│  CA3 @id:3  PUT  /pet → status=sold        @ActualizarMascota    │
│  CA4 @id:4  GET  /findByStatus ────────────────────────┐         │
│             Jackson Streaming API                       │         │
│  CA5 @id:5  Scenario Outline DDT (CSV, 3 filas) ───────┘         │
│             (flujo a/b/c/d = CA1+CA2+CA3+CA4 por fila)           │
└─────────────────────────────────────────────────────────────────-┘
                          │ CA4 / CA5-d
                          ▼
          ┌───────────────────────────────┐
          │     PetStoreSoldHelper.java   │
          │  • HttpURLConnection          │
          │  • Jackson Streaming Parser   │
          │  • Busca petId en O(1) heap   │
          │  • Retorna Map a Karate       │
          └───────────────────────────────┘
```

### Decisiones de diseño clave

| Decisión                  | Justificación                                                                    |
|---------------------------|----------------------------------------------------------------------------------|
| `callonce` en Background  | Evita múltiples POST /pet — un solo pet para CA1–CA4, datos consistentes         |
| Jackson Streaming API      | `/findByStatus` retorna miles de objetos — streaming evita OOM en heap JVM       |
| `parallel(1)`             | La API pública Petstore es sensible a condiciones de carrera — ejecución segura  |
| IDs dinámicos (`random`)  | Evita colisiones con datos preexistentes en la API pública compartida             |
| CSV para DDT (CA5)        | Separación de datos y lógica — fácil mantenimiento y extensión de casos          |

---

## 📂 Datos de Prueba

### `petCreate.json` — Payload creación de mascota

```json
{
  "id": 9981234567,
  "category": { "id": 1, "name": "Perros" },
  "name": "Firulais",
  "photoUrls": ["https://example.com/photos/firulais.jpg"],
  "tags": [{ "id": 1, "name": "jugueton" }],
  "status": "available"
}
```
> El campo `id` se sobreescribe con un valor dinámico único en runtime: `900000000 + Math.floor(Math.random() * 99999999)`.

### `petUpdate.json` — Payload actualización de mascota

```json
{
  "id": 0,
  "category": { "id": 1, "name": "Perros" },
  "name": "FirulaisActualizado",
  "photoUrls": ["https://example.com/photos/firulais-updated.jpg"],
  "tags": [{ "id": 1, "name": "jugueton" }],
  "status": "sold"
}
```
> El `id` se reemplaza con el `petId` real del pet creado en el Background antes de enviarse.

### `petCA5TestData.csv` — Datos DDT para CA5

```csv
petName,categoryName,tagName,updatedName
Kira,Gatos,tranquilo,KiraActualizada
Rex,Perros,activo,RexActualizado
Luna,Aves,curioso,LunaActualizada
```
> Genera **3 ejecuciones independientes** del flujo E2E completo. Cada fila crea su propio pet con ID único.

---

## 🔍 Solución de Problemas

### ❌ `JAVA_HOME` no está definida o JDK no encontrado

```powershell
# Verificar variable
$env:JAVA_HOME

# Configurar temporalmente en la sesión actual
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH

# Verificar
java -version
```

### ❌ `OutOfMemoryError: Java heap space`

Ya mitigado mediante Jackson Streaming API en CA4/CA5-d. Si persiste, aumentar heap en `build.gradle`:
```groovy
jvmArgs '-Xmx1g', '-Xms256m', '-XX:+UseG1GC'
```

### ❌ `Connection refused` o `SocketTimeoutException`

- Verificar conectividad a internet
- La API pública puede tener latencia alta. Aumentar timeouts en `PetStoreSoldHelper.java`:
```java
conn.setConnectTimeout(60_000);   // 60 segundos
conn.setReadTimeout(180_000);     // 3 minutos
```

### ❌ `gradlew.bat` no se ejecuta / no reconocido

```powershell
# Posicionarse en la raíz del proyecto
Set-Location "C:\Users\allumiqu\Documents\KarateApiRestBanP"
.\gradlew.bat --version
```

### ❌ Status 404 en CA2 o CA3

La Petstore API es pública y compartida; los datos pueden ser limpiados periódicamente. El `callonce` del Background asegura que el `petId` es fresco en cada ejecución. Si el fallo persiste, puede ser latencia de propagación — reejecutar la suite.

### ❌ Reportes no se generan / vacíos

Usar siempre `clean test` para evitar que Gradle marque la tarea como `UP-TO-DATE`:
```powershell
.\gradlew.bat clean test
```

---

## 📌 Referencia Rápida de Comandos

```powershell
# ── EJECUCIÓN ────────────────────────────────────────────────────────────────

# Suite completa
.\gradlew.bat clean test

# Suite completa + generar todos los reportes
.\gradlew.bat clean test aggregate

# Solo SmokeTest
.\gradlew.bat clean test -Dkarate.options="--tags @SmokeTest"

# Feature Petstore completa
.\gradlew.bat clean test -Dkarate.options="--tags @APIPetstore"

# Solo CA5 (Data Driven)
.\gradlew.bat clean test -Dkarate.options="--tags @DataDriven"

# Solo CA4 (Streaming findByStatus)
.\gradlew.bat clean test -Dkarate.options="--tags @ConsultarMascotaPorEstado"

# Excluir DDT
.\gradlew.bat clean test -Dkarate.options="--tags ~@DataDriven"

# Por ID de escenario
.\gradlew.bat clean test -Dkarate.options="--tags @id:1"

# Con entorno
.\gradlew.bat clean test -Dkarate.env=dev

# ── BUILD / UTILIDADES ───────────────────────────────────────────────────────

# Ver dependencias resueltas
.\gradlew.bat dependencies

# Debug Karate CLI
.\gradlew.bat karateDebug

# Solo compilar
.\gradlew.bat compileTestJava

# ── REPORTES ─────────────────────────────────────────────────────────────────

# Abrir reporte Karate
Start-Process "build\karate-reports\karate-summary.html"

# Abrir reporte Cucumber
Start-Process "build\cucumber-html-reports\overview-features.html"

# Ver log de ejecución
Get-Content "build\karate-reports\karate.log" -Tail 50
```

---

*Documentación técnica — KarateApiRestBanP · QA SR Automation*
