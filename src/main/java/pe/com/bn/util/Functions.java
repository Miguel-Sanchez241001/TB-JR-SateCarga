package pe.com.bn.util;

public class Functions {

    /**
     * Verifica si el String cumple con un conjunto de caracteres específicos.
     *
     * @param input      El String a verificar.
     * @param regex      La expresión regular que define los caracteres permitidos.
     * @return           True si cumple con los caracteres, de lo contrario, False.
     */
    public static boolean validateCharacters(String input, String regex) {
        return input != null && input.matches(regex);
    }

    /**
     * Rellena el String con ceros a la izquierda hasta que alcance la longitud especificada.
     *
     * @param input       El String a rellenar.
     * @param length      La longitud deseada.
     * @param minLength   La longitud mínima requerida.
     * @return            El String rellenado con ceros a la izquierda si no cumple con la longitud mínima.
     */
    public static String padLeftZeros(String input, int length, int minLength) {
        if (input == null) {
            input = "";
        }
        // Si la longitud del input es menor que minLength, se agregan ceros a la izquierda
        return input.length() < minLength ? String.format("%1$" + length + "s", input).replace(' ', '0') : input;
    }

    /**
     * Rellena el String con ceros a la derecha hasta que alcance la longitud especificada.
     *
     * @param input       El String a rellenar.
     * @param length      La longitud deseada.
     * @param minLength   La longitud mínima requerida.
     * @return            El String rellenado con ceros a la derecha si no cumple con la longitud mínima.
     */
    public static String padRightZeros(String input, int length, int minLength) {
        if (input == null) {
            input = "";
        }
        // Si la longitud del input es menor que minLength, se agregan ceros a la derecha
        return input.length() < minLength ? String.format("%1$-" + length + "s", input).replace(' ', '0') : input;
    }

    /**
     * Verifica si el String es nulo o vacío y lo reemplaza con otro valor si es así.
     *
     * @param input       El String a verificar.
     * @param replacement El valor de reemplazo si el input es nulo o vacío.
     * @return            El String original si no es nulo o vacío, de lo contrario el valor de reemplazo.
     */
    public static String replaceIfNullOrEmpty(String input, String replacement) {
        return (input == null || input.isEmpty()) ? replacement : input;
    }

    /**
     * Reemplaza los espacios en blanco en un String con el carácter de reemplazo especificado.
     *
     * @param input        El String a procesar.
     * @param replacement  El carácter que reemplazará a los espacios en blanco.
     * @return             El String con los espacios reemplazados.
     */
    public static String replaceSpaces(String input, char replacement) {
        return input != null ? input.replace(' ', replacement) : null;
    }

    /**
     * Convierte un String a mayúsculas.
     *
     * @param input El String a convertir.
     * @return El String en mayúsculas.
     */
    public static String toUpperCase(String input) {
        return input != null ? input.toUpperCase() : null;
    }

    /**
     * Convierte un String a minúsculas.
     *
     * @param input El String a convertir.
     * @return El String en minúsculas.
     */
    public static String toLowerCase(String input) {
        return input != null ? input.toLowerCase() : null;
    }
}

