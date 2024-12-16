#!/bin/bash

#------------------------------------------------------------
# Autor: Miguel Sanchez
# Descripción: Script para la limpieza de datos, ejecución de scripts secundarios y gestión de archivos y logs para el sistema SATE.
#------------------------------------------------------------

# Variables de entorno
readonly BASELOCAL=${14}
readonly SHELLDIR="$BASELOCAL/sate/sh"
readonly DATADIR="$BASELOCAL/sate/data"
readonly DATADIRBN="$BASELOCAL/sate/bn"
readonly LOGDIR="$BASELOCAL/sate/log"
readonly JARPATH="$BASELOCAL/sate/jar/"

readonly JARNAME="satecarga.jar"
readonly JARNAMEENVIO="sateenvio.jar"
readonly PROCESS="1" # 1 : Ejecucion de procedure sin salida | 2 : Ejecucion de procedure con salida


readonly CONSQL="${1}/${2}@//${3}:${4}/${5}"

readonly CONSFTPMC="sftp://${6}:${7}@${8}:${9}"
readonly CONSFTP="sftp://${10}:${11}@${12}:${13}"

readonly FECHA=$(date +'%Y%m%d')
#readonly FECHA="20241026"




readonly READMCDIR='home/MC-PROCESOS/in/TARJ_TESORO'
readonly WRITEMCDIR='home/MC-PROCESOS/out/TARJ_TESORO'

# RUTA CARPETA MEF - PRODUCCION
#readonly READMEFDIR='sftp/home/mef/in'
#readonly WRITEMEFDIR='sftp/home/mef/out'

# RUTA CARPETA MEF - DESARROLLO|CALIDAD
readonly READMEFDIR='home/opercdni/sftp/home/mef/in'
readonly WRITEMEFDIR='home/opercdni/sftp/home/mef/out'


readonly LOGFILE="sate_main_$FECHA.log"
readonly CURRENT=$(pwd)

# Validar si un parámetro está vacío
validarParametro() {
  if [ -z "$1" ]; then
    escribirLineaLog "Error: Parámetro '$2' no proporcionado."
    exit 1
  fi
}

# Validar el parámetro BASE_DIR
validarParametroBase() {
  if [ -z "$1" ]; then
    echo "Error: Parámetro '$2' no proporcionado."
    exit 1
  fi
}

# Inicialización y validación de parámetros
inicializar() {
  escribirLineaLog "INICIO DE INICIALIZACIÓN Y VALIDACIÓN DE PARÁMETROS"
  validarParametro "$1" "CONSQL_USER"
  validarParametro "$2" "CONSQL_PASS"
  validarParametro "$3" "CONSQL_IP"
  validarParametro "$4" "CONSQL_PORT"
  validarParametro "$5" "CONSQL_SID"
  validarParametro "$6" "FTP_USER"
  validarParametro "$7" "FTP_PASS"
  validarParametro "$8" "FTP_IP"
  validarParametro "$9" "FTP_PORT"
  validarParametro "${10}" "SFTP_USER"
  validarParametro "${11}" "SFTP_PASS"
  validarParametro "${12}" "SFTP_IP"
  validarParametro "${13}" "SFTP_PORT"
  escribirLineaLog "FIN DE INICIALIZACIÓN Y VALIDACIÓN DE PARÁMETROS"
}

# Limpieza de datos anteriores
limpiarDataPasada() {
  escribirLineaLog "INICIO DE LIMPIEZA DE DIRECTORIO DE DATOS"
  
  find "$DATADIR" -mindepth 1 -maxdepth 1 \
    ! -name 'MC_FAIL*' \
    ! -name 'MEF_FAIL*' \
    -exec rm -rf {} +
  
  codigoError=$?
  escribirLineaLog "FIN DE LIMPIEZA DE DIRECTORIO DE DATOS - Código de error: $codigoError"
  
  if [ $codigoError -ne 0 ]; then
    escribirLineaLog "Error al limpiar el directorio de datos - Código de error: $codigoError"
    exit $codigoError
  fi
}


# Limpieza de tablas temporales
limpiarTablasTemp() {
    cd "$JARPATH" || exit 1

    local OUTPUT
    OUTPUT=$(java -jar "$JARNAMEENVIO" "$PROCESS" "$CONSQL" "" "BN_SATE.BNPD_10_TRUNCAR_TEMP()")
    local codigoError=$?
    if [ $codigoError -ne 0 ]; then
        escribirLineaLog "Error al limpiar tablas temporales PL/SQL" "$codigoError"
        return $codigoError
    fi
    if [[ "$OUTPUT" == *"OK"* ]]; then
        escribirLineaLog "Ejecución del JAR exitosa  al limpiar tablas temporalesL"
    else
        escribirLineaLog "Error: Ejecución al limpiar tablas temporales . Mensaje: $OUTPUT"
        return 1
    fi
    cd "$CURRENT" || exit 1
    escribirLineaLog "FIN DE EJECUCIÓN DE PROCEDIMIENTO PL/SQL"

}

# Preparación del entorno
prepararEntorno() {
  escribirLineaLog "INICIO DE PREPARACIÓN DEL ENTORNO"
  export NLS_LANG=SPANISH_SPAIN.WE8MSWIN1252

  # Crear directorio de logs si no existe
  if [ ! -d "$LOGDIR" ]; then
    mkdir -p "$LOGDIR"
    escribirLineaLog "Directorio de logs creado: $LOGDIR"
  fi

  # Crear directorio de datos si no existe
  if [ ! -d "$DATADIR" ]; then
    mkdir -p "$DATADIR"
    escribirLineaLog "Directorio de datos creado: $DATADIR"
  fi
  if [ ! -d "$DATADIRBN" ]; then
    mkdir -p "$DATADIRBN"
    escribirLineaLog "Directorio de datos bn creado: $DATADIRBN"
  fi
  escribirLineaLog "FIN DE PREPARACIÓN DEL ENTORNO"
}

# Ejecución de scripts de recepción de tramas
ejecutarRecepcionTramas() {
  escribirLineaLog "INICIO DE EJECUCIÓN DE SHELLS DE RECEPCIÓN DE TRAMAS"
  #sh "$SHELLDIR/solicitud/prg_sate_solicitud_recepcion.sh" "$DATADIR" "$LOGDIR" "$JARPATH" "$CONSFTPMC/$READMCDIR" "$CONSQL" "$FECHA" "$JARNAME" "$JARNAMEENVIO"
  #sh "$SHELLDIR/asignacion/prg_sate_asignacion_recepcion.sh" "$DATADIR" "$LOGDIR" "$JARPATH" "$CONSFTP/$READMCDIR" "$CONSQL" "$FECHA" "$JARNAME" "$JARNAMEENVIO"
  sh "$SHELLDIR/cuenta/prg_sate_cuenta_recepcion.sh" "$DATADIR" "$LOGDIR" "$JARPATH" "$CONSFTP/$READMEFDIR" "$CONSQL" "$FECHA" "$JARNAME" "$JARNAMEENVIO" "$CONSFTP/$WRITEMEFDIR"
  escribirLineaLog "FIN DE EJECUCIÓN DE SHELLS DE RECEPCIÓN DE TRAMAS"
}

# Ejecución de scripts de envío de tramas
ejecutarEnvioTramas() {
  escribirLineaLog "INICIO DE EJECUCIÓN DE SHELLS DE ENVÍO DE TRAMAS"
	sh "$SHELLDIR/solicitud/prg_sate_solicitud_envio.sh" "$DATADIR" "$LOGDIR" "$CONSFTPMC/$WRITEMCDIR" "$CONSQL" "$FECHA" "$JARPATH" "$JARNAMEENVIO"
	sh "$SHELLDIR/asignacion/prg_sate_asignacion_envio.sh" "$DATADIR" "$LOGDIR" "$CONSFTPMC/$WRITEMCDIR" "$CONSQL" "$FECHA" "$JARPATH" "$JARNAMEENVIO"
	sh "$SHELLDIR/bn/prg_sate_databn.sh" "$DATADIRBN" "$LOGDIR" "$CONSQL" "$FECHA" "$JARPATH" "$JARNAMEENVIO"
  escribirLineaLog "FIN DE EJECUCIÓN DE SHELLS DE ENVÍO DE TRAMAS"
}

# Escribir en el log
escribirLineaLog() {
  fechaTiempo="$(date +'[%d/%m/%Y %H:%M:%S]')"
  if [ -z "$2" ]; then
    echo "$fechaTiempo $1" >> "$LOGDIR/$LOGFILE"
  else
    echo "$fechaTiempo $1 - Código de retorno: $2" >> "$LOGDIR/$LOGFILE"
  fi
}

# Función principal
main() {
  prepararEntorno

  escribirLineaLog "
   _____ ___  ____________
  / ___//   |/_  __/ ____/
  \\__ \\/ /| | / / / __/   
 ___/ / ___ |/ / / /___   
/____/_/  |_/_/ /_____/   TARJETA EMPRESARIAL MEF-BN-IZIPAY
  "

  validarParametroBase "${14}" "BASE_DIR"
  inicializar "$@"
  limpiarDataPasada
  limpiarTablasTemp
  ejecutarRecepcionTramas
  #ejecutarEnvioTramas
}

# Llamar a la función principal
main "$@"
