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
readonly LOGFILE="sate_asignacion_recepcion_$FECHA.log"

readonly PATH_FILE_FAIL="$DATADIR/MC_FAIL/FICTA_${FECHA}_FAILED.TXT"
readonly TYPE_PROCESS="1"
readonly TYPE_PROCESSMC="FICTA"

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
# Función para ejecutar el procedimiento de actualización
#------------------------------------------------------------
actualizarDatosTarjeta() {
    escribirLineaLog "INICIO DE EJECUCIÓN DE PROCEDIMIENTO PL/SQL"
    cd "$JAR_PATH" || exit 1
    local OUTPUT
    OUTPUT=$(java -jar "$JAR_NAME_ENVIO" '1' "$CONSQL" "" "BN_SATE.BNPD_12_ASIGNACION_ACT()")
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

    actualizarDatosTarjeta
    if [ $? -ne 0 ]; then exit 1; fi

    escribirLineaLog "********** FIN DEL SCRIPT - RECIBIR SOLICITUDES **********"
}

main
