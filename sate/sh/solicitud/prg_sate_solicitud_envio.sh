#!/bin/bash

#------------------------------------------------------------
# Autor: [Tu Nombre]
# Fecha: [Fecha]
# Hora: [Hora]
# Descripción: Este script realiza la generación de tramas de solicitudes,
#              envío de archivos al servidor FTP, y actualización de estados 
#              para el sistema SATE.
#------------------------------------------------------------

# DECLARANDO VARIABLES
readonly DATADIR=$1
readonly LOGDIR=$2
readonly CURRENT_DIR=$(pwd)
readonly CONFTP=$3
readonly CONSQL=$4
readonly FECHA=$5
readonly pathjar=$6
readonly JAR=$7
readonly SINSALIDA="1"
readonly CONSALIDA="2"
readonly CURRENT=$(pwd)
readonly FILE_PREFIX="CRTEXP19_$FECHA"
readonly DATAFILE="$FILE_PREFIX.txt"
readonly ZIPFILE="$FILE_PREFIX.zip"
readonly LOGFILE="sate_solicitudes_envio_$FECHA.log"

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
    OUTPUT=$(java -jar "$JAR" "$CONSALIDA" "$CONSQL" "$DATADIR/$DATAFILE" "BN_SATE.BNPD_00_SOLICITUD_GEN_1()")
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
# Función para enviar archivos al FTP y renombrar archivo ZIP
#------------------------------------------------------------
enviarArchivosFTP(){
    escribirLineaLog "INICIO DE ENVIO DE ARCHIVO AL FTP"
    cd $DATADIR
    zip $ZIPFILE $DATAFILE > /dev/null
    cd $CURRENT_DIR
    curl --silent -k -T $DATADIR/$ZIPFILE $CONFTP/$ZIPFILE
    codigoError=$?
    escribirLineaLog "FIN DE ENVIO DE ARCHIVO AL FTP" $codigoError

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR EN EL ENVIO DE ARCHIVO AL FTP" $codigoError
        return $codigoError
    else
        rm -f $DATADIR/$DATAFILE
        mv $DATADIR/$ZIPFILE "$DATADIR/Enviado_$ZIPFILE"
        escribirLineaLog "Archivo ZIP renombrado a Enviado_$ZIPFILE"
    fi
}

#------------------------------------------------------------
# Función para actualizar estado de tarjetas usando el JAR
#------------------------------------------------------------
actualizarEstadoTarjetas(){
    escribirLineaLog "INICIO ACTUALIZACION DE ESTADO DE TARJETAS"
    
    cd "$pathjar" || exit 1
    
    # Ejecutar el JAR para actualizar el estado de las tarjetas
    local OUTPUT
    OUTPUT=$(java -jar "$JAR" "$SINSALIDA" "$CONSQL" "" "BN_SATE.BNPD_01_SOLICITUD_GEN_2()")
    local codigoError=$?
    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error: Falló la ejecución del JAR para actualizar estado" "$codigoError"
        return $codigoError
    fi
    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa para actualización de estado de tarjetas"
    else
        escribirLineaLog "Error: Ejecución del JAR fallida. Mensaje: $OUTPUT"
        return 1
    fi

    cd "$CURRENT_DIR" || exit 1
    escribirLineaLog "FIN DE ACTUALIZACION DE ESTADO TARJETAS JAR"
}


#------------------------------------------------------------
# Función principal
#------------------------------------------------------------
main() {
    escribirLineaLog "************INICIO DEL SCRIPT - ENVIAR SOLICITUDES******************"
    preparacion
    generarArchivoTXT
    if [ $? -ne 0 ]; then exit 1; fi

    enviarArchivosFTP
    if [ $? -ne 0 ]; then exit 1; fi

    actualizarEstadoTarjetas
    if [ $? -ne 0 ]; then exit 1; fi

    escribirLineaLog "************FIN DEL SCRIPT - ENVIAR SOLICITUDES******************"
}

main
