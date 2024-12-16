#!/bin/bash

#------------------------------------------------------------
# Autor: [Tu Nombre]
# Descripción: Script para la generación de tramas de asignaciones,
#              envío de archivos al servidor FTP y actualización de estados
#              para el sistema SATE.
#------------------------------------------------------------

# Variables de entorno
readonly DATADIR="$1"
readonly LOGDIR="$2"
readonly CURRENT_DIR=$(pwd)
readonly CONFTP="$3"
readonly CONSQL="$4"
readonly DATE_SUFFIX="$5"
readonly pathjar="$6"
readonly JAR="$7"

readonly LOGFILE="sate_asignaciones_envio_$DATE_SUFFIX.LOG"
readonly FILE_PREFIX="AD302_$DATE_SUFFIX"
readonly DATAFILE="$FILE_PREFIX.TXT"
readonly ZIPFILE="$FILE_PREFIX.zip"

readonly FILE_PREFIX_MORE="ADDEXP19_$DATE_SUFFIX"
readonly DATAFILE_MORE="$FILE_PREFIX_MORE.TXT"
readonly ZIPFILE_MORE="$FILE_PREFIX_MORE.zip"

# Función para escribir en el log
escribirLineaLog() {
    fechaTiempo="$(date +'[%d/%m/%Y %H:%M:%S]')"
    if [ -z "$2" ]; then
        echo "$fechaTiempo $1" >> "$LOGDIR/$LOGFILE"
    else
        echo "$fechaTiempo $1 - Código de error: $2" >> "$LOGDIR/$LOGFILE"
    fi
}

# Generar archivo TXT de asignaciones para 'ONE'
generarArchivoTXTOne() {
    escribirLineaLog "INICIO DE GENERACIÓN DE TRAMAS DE ASIGNACIONES (ONE)"
    
    cd "$pathjar" || exit 1
    local OUTPUT
    OUTPUT=$(java -jar "$JAR" '2' "$CONSQL" "$DATADIR/$DATAFILE" "BN_SATE.BNPD_13_ASIGNACION_GEN_1('ONE')")
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR EN LA GENERACIÓN DE ASIGNACIONES (ONE)" "$codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa para la asignación (ONE)"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida para asignación (ONE). Mensaje: $OUTPUT"
        return 1
    fi

    if [ ! -f "$DATADIR/$DATAFILE" ]; then
        escribirLineaLog "ERROR: El archivo $DATAFILE no se creó correctamente"
        return 1
    fi

    cd "$CURRENT_DIR" || exit 1
    escribirLineaLog "FIN DE GENERACIÓN DE TRAMAS DE ASIGNACIONES (ONE)"
}

# Generar archivo TXT de asignaciones para 'MORE'
generarArchivoTXTMore() {
    escribirLineaLog "INICIO DE GENERACIÓN DE TRAMAS DE ASIGNACIONES (MORE)"
    
    cd "$pathjar" || exit 1
    local OUTPUT
    OUTPUT=$(java -jar "$JAR" '2' "$CONSQL" "$DATADIR/$DATAFILE_MORE" "BN_SATE.BNPD_13_ASIGNACION_GEN_1('MORE')")
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR EN LA GENERACIÓN DE ASIGNACIONES (MORE)" "$codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa para la asignación (MORE)"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida para asignación (MORE). Mensaje: $OUTPUT"
        return 1
    fi

    if [ ! -f "$DATADIR/$DATAFILE_MORE" ]; then
        escribirLineaLog "ERROR: El archivo $DATAFILE_MORE no se creó correctamente"
        return 1
    fi

    cd "$CURRENT_DIR" || exit 1
    escribirLineaLog "FIN DE GENERACIÓN DE TRAMAS DE ASIGNACIONES (MORE)"
}

# Función para comprimir archivos y eliminar los TXT
comprimirArchivos() {
    escribirLineaLog "INICIO DE COMPRESIÓN DE ARCHIVOS"
    cd "$DATADIR" || exit 1

    zip -j "$ZIPFILE" "$DATAFILE" > /dev/null
    if [ $? -ne 0 ]; then
        escribirLineaLog "ERROR AL COMPRIMIR EL ARCHIVO $DATAFILE"
        return 1
    fi

    zip -j "$ZIPFILE_MORE" "$DATAFILE_MORE" > /dev/null
    if [ $? -ne 0 ]; then
        escribirLineaLog "ERROR AL COMPRIMIR EL ARCHIVO $DATAFILE_MORE"
        return 1
    fi

    rm -f "$DATAFILE" "$DATAFILE_MORE"

    cd "$CURRENT_DIR" || exit 1
    escribirLineaLog "FIN DE COMPRESIÓN DE ARCHIVOS"
}

# Enviar archivos al FTP y renombrar archivos ZIP
enviarArchivosFTP() {
    escribirLineaLog "INICIO DE ENVÍO DE ARCHIVOS AL FTP"

    # Enviar el archivo ZIP 'ONE' al FTP
    curl --silent -k -T "$DATADIR/$ZIPFILE" "$CONFTP/$ZIPFILE"
    codigoError1=$?
    if [ $codigoError1 -ne 0 ]; then
        escribirLineaLog "ERROR EN EL ENVÍO DEL ARCHIVO $ZIPFILE AL FTP" $codigoError1
    else
        escribirLineaLog "Archivo $ZIPFILE enviado exitosamente al FTP"
		mv $DATADIR/$ZIPFILE "$DATADIR/Enviado_$ZIPFILE"
    fi

    # Enviar el archivo ZIP 'MORE' al FTP
    curl --silent -k -T "$DATADIR/$ZIPFILE_MORE" "$CONFTP/$ZIPFILE_MORE"
    codigoError2=$?
    if [ $codigoError2 -ne 0 ]; then
        escribirLineaLog "ERROR EN EL ENVÍO DEL ARCHIVO $ZIPFILE_MORE AL FTP" $codigoError2
    else
        escribirLineaLog "Archivo $ZIPFILE_MORE enviado exitosamente al FTP"
		mv $DATADIR/$ZIPFILE_MORE "$DATADIR/Enviado_$ZIPFILE_MORE"
    fi

    escribirLineaLog "FIN DE ENVÍO DE ARCHIVOS AL FTP"

    # Si alguna transferencia falló, retornar un error
    if [ $codigoError1 -ne 0 ] || [ $codigoError2 -ne 0 ]; then
        return 1
    else
        return 0
    fi
}

# Actualizar estado de asignaciones
actualizarEstadoAsignaciones() {
    escribirLineaLog "INICIO ACTUALIZACIÓN DE ESTADO DE ASIGNACIONES"
    
    cd "$pathjar" || exit 1
    local OUTPUT
    OUTPUT=$(java -jar "$JAR" '1' "$CONSQL" "" "BN_SATE.BNPD_14_ASIGNACION_GEN_2()")
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR EN LA ACTUALIZACIÓN DE ESTADO DE ASIGNACIONES" "$codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa para actualización de estado de asignaciones"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida para actualización de estado. Mensaje: $OUTPUT"
        return 1
    fi

    cd "$CURRENT_DIR" || exit 1
    escribirLineaLog "FIN ACTUALIZACIÓN DE ESTADO DE ASIGNACIONES"
}

# Función principal
main() {
    escribirLineaLog "************ INICIO DEL SCRIPT - ENVIAR ASIGNACIONES ************"

    generarArchivoTXTOne
    if [ $? -ne 0 ]; then exit 1; fi

    generarArchivoTXTMore
    if [ $? -ne 0 ]; then exit 1; fi

    comprimirArchivos
    if [ $? -ne 0 ]; then exit 1; fi

    enviarArchivosFTP
    if [ $? -ne 0 ]; then exit 1; fi

    actualizarEstadoAsignaciones
    if [ $? -ne 0 ]; then exit 1; fi

    escribirLineaLog "************ FIN DEL SCRIPT - ENVIAR ASIGNACIONES ************"
}

main
