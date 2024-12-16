#!/bin/bash

 
# DECLARANDO VARIABLES
readonly DATADIR=$1
readonly LOGDIR=$2
readonly CONSQL=$3
readonly FECHA=$4
readonly pathjar=$5
readonly JAR=$6
readonly CONSALIDA="2"
readonly CURRENT=$(pwd)
readonly FILE_PREFIX="DATOST$FECHA"
readonly DATAFILE="$FILE_PREFIX.txt"
readonly LOGFILE="sate_datosbn_$FECHA.log"

#------------------------------------------------------------
# Función para escribir en el log
#------------------------------------------------------------
escribirLineaLog(){
    fechaTiempo="$(date +'[%d/%m/%Y %H:%M:%S]:')"
    if [ -z "$2" ]; then
        echo "$fechaTiempo $1" >> "$LOGDIR/$LOGFILE"
    else
        echo "$fechaTiempo $1, código de error: $2" >> "$LOGDIR/$LOGFILE"
    fi
}

#------------------------------------------------------------
# Función para preparación inicial
#------------------------------------------------------------
preparacion(){
    escribirLineaLog "INICIO DE PREPARACIÓN"
    touch "$DATADIR/$DATAFILE"
    if [ ! -f "$DATADIR/$DATAFILE" ]; then
        escribirLineaLog "ERROR: No se pudo crear el archivo $DATAFILE"
        exit 1
    fi
	chmod u+rw "$DATADIR/$DATAFILE"

    escribirLineaLog "Archivo $DATAFILE creado correctamente"
    escribirLineaLog "FIN DE PREPARACIÓN"
}

#------------------------------------------------------------
# Función para generar archivo TXT de solicitudes usando el JAR
#------------------------------------------------------------
generarArchivoTXT(){
    escribirLineaLog "INICIO DE GENERACION DE ARCHIVO TXT DE SOLICITUDES"
    
    cd "$pathjar" || exit 1
    
    # Ejecutar el JAR con los parámetros para generar el archivo
    local OUTPUT
    OUTPUT=$(java -jar "$JAR" "$CONSALIDA" "$CONSQL" "$DATADIR/$DATAFILE" "BN_SATE.BNPD_15_ASIGNACION_BN_GEN_1()")
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error: Falló la ejecución del JAR para generar archivo TXT" "$codigoError"
        return $codigoError
    fi
    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa. Archivo generado: $DATADIR/$DATAFILE"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida. Mensaje: $OUTPUT"
        return 1
    fi
    if [ ! -f "$DATADIR/$DATAFILE" ]; then
        escribirLineaLog "Error: El archivo $DATAFILE no se creó correctamente"
        return 1
    fi
    cd "$CURRENT_DIR" || exit 1
    escribirLineaLog "FIN DE GENERACION DE ARCHIVO TXT DE SOLICITUDES"
}
#------------------------------------------------------------
# Función principal
#------------------------------------------------------------
main() {
    escribirLineaLog "************INICIO DEL SCRIPT - ENVIAR SOLICITUDES******************"
    preparacion
    generarArchivoTXT
    if [ $? -ne 0 ]; then exit 1; fi
    escribirLineaLog "************FIN DEL SCRIPT - ENVIAR SOLICITUDES******************"
}

main
