#!/bin/bash

# Definir los parámetros
DB_CONNECTION="bn_sate/bn_sate@//10.7.12.177:1521/orades"
PATH_FILE="logs/FICTA19240227.txt"
TYPE_PROCESS="2"
TYPE_PROCESSMC="FICTA"
# Ejecutar el JAR con los parámetros
OUTPUT=$(java -Dlog4j.configuration=file:log4j.properties -jar satecarga.jar "$DB_CONNECTION" "$PATH_FILE" "$TYPE_PROCESS" "$TYPE_PROCESSMC")

# Capturar la respuesta y verificar si es OK o FAILED
if [[ $OUTPUT == *"OK"* ]]; then
    echo "El proceso se completó exitosamente: OK"
    exit 0
else
    echo "El proceso falló: FAILED"
    exit 1
fi
