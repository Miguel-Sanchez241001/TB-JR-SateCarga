#!/bin/bash

# Definir los parámetros
DB_CONNECTION="bn_sate/bn_sate@//localhost:1521/XE"
PATH_FILE="logs/TTPHAB_20240828_01_MEF.TXT"
LOG_FILE="logs/aplication.log"
TYPE_PROCESS="2"

# Ejecutar el JAR con los parámetros
OUTPUT=$(java -jar saterecepcionjar.jar "$DB_CONNECTION" "$PATH_FILE" "$LOG_FILE" "$TYPE_PROCESS")

# Capturar la respuesta y verificar si es OK o FAILED
if [[ $OUTPUT == *"OK"* ]]; then
    echo "El proceso se completó exitosamente: OK"
    exit 0
else
    echo "El proceso falló: FAILED"
    exit 1
fi
