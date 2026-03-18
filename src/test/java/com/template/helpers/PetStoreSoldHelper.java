package com.template.helpers;

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Helper para el CA4 del flujo E2E de PetStore.
 *
 * <p>Problema: GET /pet/findByStatus?status=sold retorna miles de registros en la API pública.
 * Cargar el array completo en memoria provoca {@code OutOfMemoryError: Java heap space} en Karate.
 *
 * <p>Solución: Jackson Streaming API parsea el stream byte a byte sin materializar el array.
 * Solo el objeto cuyo {@code id} coincide con el pet del test se almacena en memoria → O(1) heap.
 *
 * <p>Uso desde Karate:
 * <pre>
 *   * def PetStoreSoldHelper = Java.type('com.template.helpers.PetStoreSoldHelper')
 *   * def foundPet = PetStoreSoldHelper.findPetByIdInSoldStream(petId)
 * </pre>
 */
public class PetStoreSoldHelper {

    private static final Logger LOGGER   = Logger.getLogger(PetStoreSoldHelper.class.getName());
    private static final String SOLD_URL = "https://petstore.swagger.io/v2/pet/findByStatus?status=sold";
    private static final String STRATEGY = "Jackson Streaming API — O(1) heap: solo el objeto buscado se materializa, el resto del stream se descarta";

    private PetStoreSoldHelper() { /* utility class — no instances */ }

    /**
     * Ejecuta {@code GET /pet/findByStatus?status=sold} y busca en el stream el objeto
     * cuyo campo {@code id} coincide con {@code targetPetIdObj}.
     *
     * <p>Cumple el requisito de negocio: "Consultar la mascota MODIFICADA por estatus".
     * Confirma que el pet específico del flujo E2E aparece en la lista de vendidos.
     *
     * @param targetPetIdObj petId proveniente de Karate (Number / Long / Integer / Double)
     * @return Map con: id, name, status, httpStatus, endpoint, strategy
     * @throws RuntimeException si HTTP != 200 o si el pet no se encuentra en el stream
     */
    public static Map<String, Object> findPetByIdInSoldStream(Object targetPetIdObj) {
        long targetPetId = ((Number) targetPetIdObj).longValue();
        LOGGER.log(Level.INFO, "CA4 - Buscando petId={0} en {1}", new Object[]{targetPetId, SOLD_URL});

        HttpURLConnection conn = null;
        try {
            URL url = new URL(SOLD_URL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");
            conn.setConnectTimeout(30_000);
            conn.setReadTimeout(120_000);

            int httpStatus = conn.getResponseCode();
            if (httpStatus != 200) {
                throw new RuntimeException("CA4: Se esperaba HTTP 200 pero la API retornó: " + httpStatus);
            }

            return streamSearchById(conn.getInputStream(), targetPetId, httpStatus);

        } catch (RuntimeException re) {
            throw re;
        } catch (Exception e) {
            throw new RuntimeException(
                    "CA4: Error al consumir GET /pet/findByStatus?status=sold — " + e.getMessage(), e);
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * Parsea el stream JSON elemento a elemento buscando el objeto con {@code id == targetPetId}.
     *
     * <p>Por cada objeto del array se leen solo los campos necesarios ({@code id}, {@code name},
     * {@code status}); los campos anidados ({@code category}, {@code photoUrls}, {@code tags})
     * se saltan con {@code skipChildren()} sin acumular memoria.
     * Una vez encontrado el objeto, el resto del stream no se lee.
     */
    private static Map<String, Object> streamSearchById(
            InputStream is, long targetPetId, int httpStatus) throws Exception {

        JsonFactory factory = new JsonFactory();
        int scanned = 0;

        try (JsonParser parser = factory.createParser(is)) {

            assertToken(parser.nextToken(), JsonToken.START_ARRAY);

            while (parser.nextToken() != JsonToken.END_ARRAY) {
                assertToken(parser.getCurrentToken(), JsonToken.START_OBJECT);
                scanned++;

                long   currentId     = -1L;
                String currentName   = null;
                String currentStatus = null;

                while (parser.nextToken() != JsonToken.END_OBJECT) {
                    String field = parser.getCurrentName();
                    parser.nextToken(); // avanzar al valor del campo
                    switch (field) {
                        case "id":
                            currentId = parser.getLongValue();
                            break;
                        case "name":
                            currentName = parser.getCurrentToken() == JsonToken.VALUE_NULL
                                    ? null : parser.getText();
                            break;
                        case "status":
                            currentStatus = parser.getCurrentToken() == JsonToken.VALUE_NULL
                                    ? null : parser.getText();
                            break;
                        default:
                            parser.skipChildren(); // category, photoUrls, tags → descartados
                            break;
                    }
                }

                if (currentId == targetPetId) {
                    LOGGER.log(Level.INFO,
                            "CA4 - Pet encontrado en posición #{0}: id={1}, status={2}",
                            new Object[]{scanned, currentId, currentStatus});

                    Map<String, Object> result = new HashMap<>();
                    result.put("id",         currentId);
                    result.put("name",       currentName);
                    result.put("status",     currentStatus);
                    result.put("httpStatus", httpStatus);
                    result.put("endpoint",   SOLD_URL);
                    result.put("strategy",   STRATEGY);
                    return result; // stream restante descartado → O(1) memoria
                }
            }
        }

        throw new RuntimeException(
                "CA4: El pet con id=" + targetPetId
                + " no fue encontrado en GET /pet/findByStatus?status=sold"
                + " tras escanear " + scanned + " registros. "
                + "Verificar que CA3 actualizó el estatus correctamente "
                + "o que la API pública conserva el estado del pet.");
    }

    private static void assertToken(JsonToken actual, JsonToken expected) {
        if (actual != expected) {
            throw new RuntimeException(
                    "CA4: Token inesperado en stream — esperado: " + expected + ", obtenido: " + actual);
        }
    }
}
