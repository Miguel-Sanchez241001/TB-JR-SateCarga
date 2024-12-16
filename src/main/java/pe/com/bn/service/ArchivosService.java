package pe.com.bn.service;

import com.google.inject.Inject;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.model.InputParametros;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.List;

public class ArchivosService {

    private static final Logger log = Logger.getLogger(ArchivosService.class);
    private final InputParametros input;

    @Inject
    public ArchivosService(InputParametros input) {
        this.input = input;
    }

    /**
     * Inicializa el archivo de respuesta, creando el archivo si no existe.
     */
    public void initArchivoRespuesta() throws ProcessException {
        try {
            File responseFile = new File(input.getPathFileFail());
            input.setResponseProccessFail(responseFile);

            if (!responseFile.exists()) {
                FileUtils.touch(responseFile);
                log.info("Archivo de respuesta creado: " + responseFile.getPath());
            }
        } catch (IOException e) {
            log.error("Error al crear el archivo de respuesta: " + e.getMessage(), e);
            throw new ProcessException("Error creando archivo de respuesta en: " + input.getPathFileFail(), e);
        }
    }

    /**
     * Guarda un mensaje de error en el archivo de errores.
     */
    public void saveFailError(String mensaje) throws ProcessException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(input.getResponseProccessFail(), true))) {
            writer.write(mensaje);
            writer.newLine();
        } catch (IOException e) {
            log.error("Error al escribir en el archivo de errores: " + e.getMessage(), e);
            throw new ProcessException("Error al escribir en el archivo de errores: " + input.getResponseProccessFail().getPath(), e);
        }
    }

    /**
     * Agrega un mensaje como encabezado en el archivo de errores.
     */
    public void saveFailErrorHead(String mensaje) throws ProcessException {
        try {
            File file = input.getResponseProccessFail();

            // Leer todo el contenido del archivo
            List<String> lineas = FileUtils.readLines(file, String.valueOf(StandardCharsets.UTF_8));

            // Insertar el mensaje al principio
            lineas.add(0, mensaje);

            // Sobrescribir el archivo con las líneas actualizadas
            FileUtils.writeLines(file, String.valueOf(StandardCharsets.UTF_8), lineas);
        } catch (IOException e) {
            log.error("Error al escribir en la primera línea del archivo de errores: " + e.getMessage(), e);
            throw new ProcessException("Error al escribir en la primera línea del archivo de errores: " + input.getResponseProccessFail().getPath(), e);
        }
    }

    /**
     * Elimina el archivo de errores si existe.
     */
    public void deleteArchivoRespuesta() throws ProcessException {
        try {
            File file = input.getResponseProccessFail();
            if (file.exists() && file.delete()) {
                log.info("Archivo de respuesta eliminado: " + file.getPath());
            } else {
                log.warn("El archivo de respuesta no pudo ser eliminado: " + file.getPath());
            }
        } catch (Exception e) {
            log.error("Error al eliminar el archivo de respuesta: " + e.getMessage(), e);
            throw new ProcessException("Error al eliminar el archivo de respuesta: " + input.getResponseProccessFail().getPath(), e);
        }
    }

    /**
     * Lee todas las líneas del archivo de errores y las devuelve como una lista.
     */
    public List<String> readArchivoRespuesta() throws ProcessException {
        try {
            File file = input.getResponseProccessFail();
            return FileUtils.readLines(file, String.valueOf(StandardCharsets.UTF_8));
        } catch (IOException e) {
            log.error("Error al leer el archivo de respuesta: " + e.getMessage(), e);
            throw new ProcessException("Error al leer el archivo de respuesta: " + input.getResponseProccessFail().getPath(), e);
        }
    }

    /**
     * Limpia el contenido del archivo de errores, dejándolo vacío.
     */
    public void clearArchivoRespuesta() throws ProcessException {
        try {
            File file = input.getResponseProccessFail();
            FileUtils.writeLines(file, "", (Collection) StandardCharsets.UTF_8);
            log.info("Archivo de respuesta limpiado: " + file.getPath());
        } catch (IOException e) {
            log.error("Error al limpiar el archivo de respuesta: " + e.getMessage(), e);
            throw new ProcessException("Error al limpiar el archivo de respuesta: " + input.getResponseProccessFail().getPath(), e);
        }
    }
}
