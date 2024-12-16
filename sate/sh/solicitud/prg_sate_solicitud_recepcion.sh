#!/bin/bash

#------------------------------------------------------------
# Autor: [Tu Nombre]
# Descripción: Este script descarga archivos de datos desde un servidor FTP,
#              carga los datos en tablas de base de datos usando un JAR proporcionado,
#              y ejecuta procedimientos PL/SQL para procesar la información.
#------------------------------------------------------------

# DECLARACIÓN DE VARIABLES
readonly DATADIR="$1"
readonly LOGDIR="$2"
readonly JAR_PATH="$3"
readonly CONSFTP="$4"
readonly CONSQL="$5"
readonly FECHA="$6"
readonly JAR_NAME="$7"
readonly JAR_NAME_ENVIO="$8"
readonly CURRENT=$(pwd)
readonly DATAFILEPATTERN='^INTERFA1[0-9]{6}\.zip$'
readonly DATAFILEPATTERNTXT="FICTA[0-9]{8}\.txt"
declare DATAFILE=''
declare DATAFILETXT=''
readonly LOGFILE="sate_solicitud_recepcion_$FECHA.log"

readonly PATH_FILE_FAIL="$DATADIR/MC_FAIL/FICTA_${FECHA}_FAILED.TXT"
readonly TYPE_PROCESS="1"
readonly TYPE_PROCESSMC="FICTA"
readonly SINSALIDA="1"
readonly CONSALIDA="2"
#------------------------------------------------------------
# Función para escribir en el log
#------------------------------------------------------------
escribirLineaLog() {
    local fechaTiempo
    fechaTiempo="$(date +'[%d/%m/%Y %H:%M:%S]')"
    if [ -z "$2" ]; then
        echo "$fechaTiempo $1" >> "$LOGDIR/$LOGFILE"
    else
        echo "$fechaTiempo $1 - Código de error: $2" >> "$LOGDIR/$LOGFILE"
    fi
}

#------------------------------------------------------------
# Función para crear el directorio MC_FAIL
#------------------------------------------------------------
crearDirectorioMC_FAIL() {
    escribirLineaLog "INICIO DE CREACIÓN DE DIRECTORIO MC_FAIL"
    if [ ! -d "$DATADIR/MC_FAIL" ]; then
        mkdir -p "$DATADIR/MC_FAIL"
        local codigoError=$?
        if [ $codigoError -ne 0 ]; then
            escribirLineaLog "ERROR AL CREAR EL DIRECTORIO MC_FAIL" "$codigoError"
            return $codigoError
        fi
        escribirLineaLog "Directorio MC_FAIL creado exitosamente"
    else
        escribirLineaLog "El directorio MC_FAIL ya existe"
    fi
    escribirLineaLog "FIN DE CREACIÓN DE DIRECTORIO MC_FAIL"
}

#------------------------------------------------------------
# Función para cargar archivos desde el FTP
#------------------------------------------------------------
cargarDataFile() {
    escribirLineaLog "INICIO DE CARGA DE ARCHIVO DESDE EL FTP"

    local archivos
    archivos=$(curl --silent -k "$CONSFTP/" -l)

    if [ $? -ne 0 ]; then
        escribirLineaLog "Error: Falló la obtención de la lista de archivos desde el FTP"
        return 1
    fi

    if [ -n "$archivos" ]; then
        local sorted
        sorted=$(printf '%s\n' $archivos | sort -nr)

        for arg in $sorted; do
            if [[ $arg =~ $DATAFILEPATTERN ]]; then
                DATAFILE="$arg"
                escribirLineaLog "Archivo encontrado: $DATAFILE"
                break
            fi
        done
    fi

    if [ -z "$DATAFILE" ]; then
        escribirLineaLog "NO SE ENCONTRÓ EL ARCHIVO EN EL FTP"
        return 1
    fi

    escribirLineaLog "FIN DE CARGA DE ARCHIVO DESDE EL FTP"
}

#------------------------------------------------------------
# Función para obtener archivos del FTP
#------------------------------------------------------------
obtenerArchivoFTP() {
    escribirLineaLog "INICIO DE DESCARGA DE ARCHIVO DESDE EL FTP"

    curl --silent -k "$CONSFTP/$DATAFILE" -o "$DATADIR/$DATAFILE"
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error: Falló la descarga del archivo desde el FTP" "$codigoError"
        return $codigoError
    fi

    escribirLineaLog "Archivo $DATAFILE descargado correctamente"

    # Descomprimir el archivo
    unzip -o "$DATADIR/$DATAFILE" -d "$DATADIR" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        escribirLineaLog "Error: Falló la descompresión del archivo $DATAFILE"
        return 1
    fi

    escribirLineaLog "Archivo $DATAFILE descomprimido correctamente"

    escribirLineaLog "FIN DE DESCARGA DE ARCHIVO DESDE EL FTP"
}

#------------------------------------------------------------
# Función para cargar datos en la base de datos usando JAR
#------------------------------------------------------------
cargarDatosConJar() {
    escribirLineaLog "INICIO DE BÚSQUEDA Y CARGA DE DATOS CON JAR"

    local archivoEncontrado
    archivoEncontrado=$(find "$DATADIR" -maxdepth 1 -type f | grep -E $DATAFILEPATTERNTXT)

    if [ -z "$archivoEncontrado" ]; then
        escribirLineaLog "NO SE ENCONTRÓ EL ARCHIVO QUE CUMPLA CON EL PATRÓN"
        return 1
    fi

    escribirLineaLog "Archivo encontrado: $archivoEncontrado"

    # Ejecutar el JAR proporcionado con los parámetros requeridos
    cd "$JAR_PATH" || exit 1

    local OUTPUT
    OUTPUT=$(java -Dlog4j.configuration=file:log4j.properties -jar "$JAR_NAME" "$CONSQL" "$archivoEncontrado" "$PATH_FILE_FAIL" "$TYPE_PROCESS" "$TYPE_PROCESSMC")

    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error: Falló la ejecución del JAR" "$codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida. Mensaje: $OUTPUT"
        return 1
    fi

     cd "$CURRENT" || exit 1
    escribirLineaLog "FIN DE CARGA DE DATOS CON JAR"
}

#------------------------------------------------------------
# Función para eliminar archivos descargados
#------------------------------------------------------------
eliminarArchivos() {
    escribirLineaLog "INICIO DE ELIMINACIÓN DE ARCHIVOS DESCARGADOS"
    rm -f "$DATADIR/$DATAFILE" 
	rm -f "$DATADIR"/*.txt
    local codigoError=$?
    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error al eliminar archivos" "$codigoError"
        return $codigoError
    fi
    escribirLineaLog "Archivos eliminados correctamente"
    escribirLineaLog "FIN DE ELIMINACIÓN DE ARCHIVOS DESCARGADOS"
}

#------------------------------------------------------------
# Función para ejecutar el procedimiento de actualización
#------------------------------------------------------------
actualizarDatosTarjeta() {
    escribirLineaLog "INICIO DE EJECUCIÓN DE PROCEDIMIENTO PL/SQL"

    cd "$JAR_PATH" || exit 1

    local OUTPUT
    OUTPUT=$(java -jar "$JAR_NAME_ENVIO" "$SINSALIDA" "$CONSQL" "" "BN_SATE.BNPD_02_SOLICITUD_ACT()")
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error al ejecutar el JAR para el procedimiento PL/SQL" "$codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa para el procedimiento PL/SQL"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida. Mensaje: $OUTPUT"
        return 1
    fi

    cd "$CURRENT" || exit 1

    escribirLineaLog "FIN DE EJECUCIÓN DE PROCEDIMIENTO PL/SQL"
}


#------------------------------------------------------------
# Función principal
#------------------------------------------------------------
main() {
    escribirLineaLog "********** INICIO DEL SCRIPT - RECIBIR SOLICITUDES **********"

    crearDirectorioMC_FAIL
    if [ $? -ne 0 ]; then exit 1; fi

    cargarDataFile
    if [ $? -ne 0 ]; then exit 1; fi

    obtenerArchivoFTP
    if [ $? -ne 0 ]; then exit 1; fi

    cargarDatosConJar
    if [ $? -ne 0 ]; then exit 1; fi

    eliminarArchivos
    if [ $? -ne 0 ]; then exit 1; fi

    actualizarDatosTarjeta
    if [ $? -ne 0 ]; then exit 1; fi

    escribirLineaLog "********** FIN DEL SCRIPT - RECIBIR SOLICITUDES **********"
}
main
