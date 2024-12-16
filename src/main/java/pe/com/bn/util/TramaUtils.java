package pe.com.bn.util;

public class TramaUtils {
    // Método LPAD: agrega caracteres a la izquierda hasta llegar al tamaño deseado
    public static String lpad(String input, int length, char padChar) {
        // Si el input es nulo, lo tratamos como una cadena vacía
        if (input == null) {
            input = "";
        }

        // Si la longitud del input es mayor o igual a la longitud requerida, devolver el input tal como está
        if (input.length() >= length) {
            return input;
        }

        // Crear el StringBuilder para el relleno
        StringBuilder padded = new StringBuilder();

        // Añadir el carácter de relleno hasta alcanzar la longitud requerida
        while (padded.length() + input.length() < length) {
            padded.append(padChar);
        }

        // Añadir el input al final del relleno
        padded.append(input);

        // Devolver la cadena con el relleno
        return padded.toString();
    }


    // Método RPAD: agrega caracteres a la derecha hasta llegar al tamaño deseado
    public static String rpad(String input, int length, char padChar) {

        if (input == null) {
            input = "";
        }
        if (input.length() >= length) {
            return input;
        }
        StringBuilder padded = new StringBuilder(input);
        while (padded.length() < length) {
            padded.append(padChar);
        }
        return padded.toString();
    }
}
