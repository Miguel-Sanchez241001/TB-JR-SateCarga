package pe.com.bn.util;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

public class ArchivoUtil {

    /**
     * Escribe un texto al final de un archivo.
     */
    public static void escribirAlFinal(String rutaArchivo, String texto) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(rutaArchivo, true))) {
            writer.write(texto);
            writer.newLine();
        }
    }

    /**
     * Escribe un texto al inicio de un archivo.
     */
    public static void escribirAlInicio(String rutaArchivo, String texto) throws IOException {
        List<String> lineas = leerTodasLasLineas(rutaArchivo); // Leer el contenido actual
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(rutaArchivo))) {
            writer.write(texto); // Escribir el nuevo texto
            writer.newLine();
            for (String linea : lineas) {
                writer.write(linea); // Escribir las líneas anteriores
                writer.newLine();
            }
        }
    }

    /**
     * Lee todas las líneas de un archivo.
     */
    public static List<String> leerTodasLasLineas(String rutaArchivo) throws IOException {
        return Files.readAllLines(Paths.get(rutaArchivo));
    }

    /**
     * Lee todas las líneas excepto la primera línea.
     */
    public static List<String> leerLineasExceptoPrimera(String rutaArchivo) throws IOException {
        List<String> lineas = leerTodasLasLineas(rutaArchivo);
        if (!lineas.isEmpty()) {
            lineas.remove(0); // Eliminar la primera línea
        }
        return lineas;
    }

    /**
     * Cuenta cuántas líneas tiene un archivo.
     */
    public static int contarLineas(String rutaArchivo) throws IOException {
        return leerTodasLasLineas(rutaArchivo).size();
    }

    /**
     * Escribe una lista de líneas al archivo (sobreescribiendo).
     */
    public static void escribirLineas(String rutaArchivo, List<String> lineas) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(rutaArchivo))) {
            for (String linea : lineas) {
                writer.write(linea);
                writer.newLine();
            }
        }
    }

    /**
     * Inserta texto en una línea específica del archivo.
     */
    public static void insertarEnLinea(String rutaArchivo, String texto, int numeroLinea) throws IOException {
        List<String> lineas = leerTodasLasLineas(rutaArchivo);
        if (numeroLinea > 0 && numeroLinea <= lineas.size() + 1) {
            lineas.add(numeroLinea - 1, texto); // Insertar el texto en la posición específica
            escribirLineas(rutaArchivo, lineas); // Sobreescribir el archivo
        } else {
            throw new IllegalArgumentException("Número de línea fuera de rango.");
        }
    }

    /**
     * Elimina una línea específica del archivo.
     */
    public static void eliminarLinea(String rutaArchivo, int numeroLinea) throws IOException {
        List<String> lineas = leerTodasLasLineas(rutaArchivo);
        if (numeroLinea > 0 && numeroLinea <= lineas.size()) {
            lineas.remove(numeroLinea - 1); // Eliminar la línea específica
            escribirLineas(rutaArchivo, lineas); // Sobreescribir el archivo
        } else {
            throw new IllegalArgumentException("Número de línea fuera de rango.");
        }
    }
}

