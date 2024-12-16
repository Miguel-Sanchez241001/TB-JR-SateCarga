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
readonly CONSFTPWRITE="$9"


readonly CURRENT=$(pwd)
readonly DATAFILEPATTERN='^TTPHAB_[0-9]{8}_[0-9]{2}_MEF\.(txt|TXT)$'
declare DATAFILE=''
readonly LOGFILE="sate_recepcion_cuenta_$FECHA.log"
readonly SINSALIDA="1"



declare PATH_FAIL="$DATADIR/MEF_FAIL"
readonly FILE_PATTERN="TTPAUT_[0-9]{8}_VAL_[0-9]{2}_BN\.txt$"
declare FILE_FAIL="TTPAUT_$6_VAL_NN_BN.txt"
declare MOST_RECENT_FILE=""



readonly TYPE_PROCESS_MEF="2"
readonly TYPE_PROCESSMC=""

#------------------------------------------------------------
# Función para escribir en el log
#------------------------------------------------------------
escribirLineaLog(){
    local fechaTiempo="$(date +'[%d/%m/%Y %H:%M:%S]:')"
    if [ -z "$2" ]; then
        echo "$fechaTiempo $1" >> "$LOGDIR/$LOGFILE"
    else
        echo "$fechaTiempo $1 - Código de error: $2" >> "$LOGDIR/$LOGFILE"
    fi
}

#------------------------------------------------------------
# Función para crear el directorio MEF_FAIL dentro de DATADIR
#------------------------------------------------------------
crearDirectorioMEF_FAIL(){
    escribirLineaLog "INICIO DE CREACIÓN DE DIRECTORIO MEF_FAIL"
    if [ ! -d "$DATADIR/MEF_FAIL" ]; then
        mkdir -p "$DATADIR/MEF_FAIL"
        local codigoError=$?
        if [ $codigoError -ne 0 ]; then
            escribirLineaLog "ERROR AL CREAR EL DIRECTORIO MEF_FAIL" "$codigoError"
            return $codigoError
        fi
        escribirLineaLog "Directorio MEF_FAIL creado exitosamente"
    else
        escribirLineaLog "El directorio MEF_FAIL ya existe"
    fi
    escribirLineaLog "FIN DE CREACIÓN DE DIRECTORIO MEF_FAIL"
}

#------------------------------------------------------------
# Función para cargar archivos desde el FTP
#------------------------------------------------------------
cargarDataFile(){
    escribirLineaLog "INICIO DE BÚSQUEDA DE ARCHIVO EN EL FTP"
    local archivos=$(curl --silent -k "$CONSFTP/" -l)
    if [ -n "$archivos" ]; then
        local sorted=$(printf '%s\n' "$archivos" | sort -nr)
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
    escribirLineaLog "FIN DE BÚSQUEDA DE ARCHIVO EN EL FTP"
}

#------------------------------------------------------------
# Función para obtener archivos del FTP
#------------------------------------------------------------
obtenerArchivoFTP(){
    escribirLineaLog "INICIO DE DESCARGA DE ARCHIVO DESDE EL FTP"
    curl --silent -k "$CONSFTP/$DATAFILE" -o "$DATADIR/$DATAFILE"
    local codigoError=$?
    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR AL DESCARGAR EL ARCHIVO" "$codigoError"
        return $codigoError
    fi
    escribirLineaLog "FIN DE DESCARGA DE ARCHIVO DESDE EL FTP"
}

#------------------------------------------------------------
# Función para cargar datos en la base de datos usando JAR
#------------------------------------------------------------
cargarDatosConJar(){
    escribirLineaLog "INICIO DE CARGA DE DATOS CON JAR"
    cd "$JAR_PATH" || exit 1

    local OUTPUT
    OUTPUT=$(java -Dlog4j.configuration=file:log4j.properties -jar "$JAR_NAME" "$CONSQL" "$DATADIR/$DATAFILE" "$PATH_FAIL/$FILE_FAIL" "$TYPE_PROCESS_MEF" "$TYPE_PROCESSMC")
    local codigoError=$?
    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "El proceso Java retornó un código de error: $codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "El proceso se completó exitosamente."
    else
        escribirLineaLog "El proceso falló: $OUTPUT"
        return 1
    fi

    cd "$CURRENT" || exit 1
    escribirLineaLog "FIN DE CARGA DE DATOS CON JAR"
}









enviarValidacionMef(){
    escribirLineaLog "INICIO DE ENVIO DE ARCHIVO DE VALIDACIONES MEF"
    cd "$PATH_FAIL" || exit 1

	MOST_RECENT_FILE=$(find . -maxdepth 1 -type f -regextype posix-extended -regex "./$FILE_PATTERN" | head -n 1)
	MOST_RECENT_FILE=$(basename "$MOST_RECENT_FILE")
	cd "$CURRENT" || exit 1
	if [ -z "$MOST_RECENT_FILE" ]; then
        escribirLineaLog "No se encontró ningún archivo que coincida con el patron."
        exit 1
    fi

	curl --silent -k -T $PATH_FAIL/$MOST_RECENT_FILE $CONSFTPWRITE/$MOST_RECENT_FILE
    codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR EN EL ENVIO DE ARCHIVO AL FTP" $codigoError
        return $codigoError
    else
        mv $PATH_FAIL/$MOST_RECENT_FILE "$PATH_FAIL/Enviado_$MOST_RECENT_FILE"
        escribirLineaLog "Archivo validacion renombrado a Enviado_$MOST_RECENT_FILE"
    fi
	  
    escribirLineaLog "FIN DE ENVIO DE ARCHIVO VALIDACIOENS AL FTP" $codigoError
}

#------------------------------------------------------------
# Función para eliminar archivos descargados
#------------------------------------------------------------
eliminarArchivo(){
    escribirLineaLog "INICIO DE ELIMINACIÓN DE ARCHIVO DESCARGADO"
    rm -f "$DATADIR/$DATAFILE"
    local codigoError=$?
    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR AL ELIMINAR EL ARCHIVO" "$codigoError"
        return $codigoError
    fi
    escribirLineaLog "FIN DE ELIMINACIÓN DE ARCHIVO DESCARGADO"
}

#------------------------------------------------------------
# Función para ejecutar el procedimiento de actualización
#------------------------------------------------------------
ejecutarProcedimiento() {
    escribirLineaLog "INICIO DE EJECUCION DE PROCEDIMIENTO PL/SQL"
    
    cd "$JAR_PATH" || exit 1

    local OUTPUT
    OUTPUT=$(java -jar "$JAR_NAME_ENVIO" "$SINSALIDA" "$CONSQL" "" "BN_SATE.BNPD_09_CUENTA_ACT()")
    local codigoError=$?

    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "ERROR AL EJECUTAR EL JAR PARA EL PROCEDIMIENTO PL/SQL" "$codigoError"
        return $codigoError
    fi

    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecucion del JAR exitosa para el procedimiento PL/SQL"
    else
        escribirLineaLog "Error: Ejecucion del JAR fallida. Mensaje: $OUTPUT"
        return 1
    fi
    cd "$CURRENT" || exit 1

    escribirLineaLog "FIN DE EJECUCION DE PROCEDIMIENTO PL/SQL"
}


#------------------------------------------------------------
# Función principal
#------------------------------------------------------------
main() {
    escribirLineaLog "********** INICIO DEL SCRIPT - RECIBIR CUENTAS **********"

    crearDirectorioMEF_FAIL
    if [ $? -ne 0 ]; then exit 1; fi

    cargarDataFile
    if [ $? -ne 0 ]; then exit 1; fi

    obtenerArchivoFTP
    if [ $? -ne 0 ]; then exit 1; fi

    cargarDatosConJar
    if [ $? -ne 0 ]; then exit 1; fi

	enviarValidacionMef
    if [ $? -ne 0 ]; then exit 1; fi

    eliminarArchivo
    if [ $? -ne 0 ]; then exit 1; fi

    #ejecutarProcedimiento
    if [ $? -ne 0 ]; then exit 1; fi

    escribirLineaLog "********** FIN DEL SCRIPT - RECIBIR CUENTAS **********"
}

main
