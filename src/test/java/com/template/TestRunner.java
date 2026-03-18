package com.template;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import net.minidev.json.JSONArray;
import net.minidev.json.parser.JSONParser;
import net.minidev.json.parser.ParseException;
import org.apache.commons.io.FileUtils;
import org.junit.Test;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import static org.junit.Assert.assertTrue;

public class TestRunner {

    private static final Logger logger = Logger.getLogger(TestRunner.class.getName());

    @Test
    public void testRunner() throws IOException {
        Results results = Runner
                .path("src/test/java/com/template/features/petstore")
                .tags("@APIPetstore")
                .outputCucumberJson(true)
                .parallel(1);

        generateReport("build/karate-reports");
        assertTrue(results.getErrorMessages(), results.getFailCount() == 0);
    }

    private static void generateReport(String karateOutputPath) throws IOException {
        Collection<File> jsonFiles = FileUtils.listFiles(
                new File(karateOutputPath), new String[]{"json"}, true);

        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        JSONArray karateJson  = new JSONArray();

        jsonFiles.forEach(file -> {
            karateJson.add(getReportJsonByFile(file.getAbsolutePath()));
            jsonPaths.add(file.getAbsolutePath());
        });

        String jsonOutputDir = karateOutputPath + "/json";
        Files.createDirectories(Paths.get(jsonOutputDir));
        Files.write(Paths.get(jsonOutputDir + "/karate.json"),
                karateJson.toJSONString().getBytes());

        Configuration config = new Configuration(new File("build"), "Petstore API - Flujo E2E");
        new ReportBuilder(jsonPaths, config).generateReports();
    }

    private static Object getReportJsonByFile(String filePath) {
        try (FileReader reader = new FileReader(filePath)) {
            JSONArray array = (JSONArray) new JSONParser().parse(reader);
            return array.isEmpty() ? null : array.get(0);
        } catch (IOException | ParseException e) {
            logger.log(Level.WARNING, "Error al leer reporte JSON: {0}", filePath);
            return null;
        }
    }
}