#!/bin/bash

# Archivo donde se guardarán las respuestas
ARCHIVO_LOG="$HOME/.respuestas_diarias.txt"

# Obtener fecha y hora actual
FECHA=$(date "+%Y-%m-%d %H:%M:%S")

# Preguntar cómo está
echo "Buenos, cómo va el dia?"
read respuesta

# Verificar que no esté vacío
if [ -z "$respuesta" ]; then
    echo "¡Está bien, no hay problema!"
    exit 0
fi

# Guardar respuesta con formato: FECHA | USUARIO | RESPUESTA
echo "$FECHA | $USER | $respuesta" >> "$ARCHIVO_LOG"

# Ordenar el archivo por fecha (las entradas más recientes primero)
sort -r "$ARCHIVO_LOG" -o "$ARCHIVO_LOG"

# Mensaje de confirmación
echo "¡Genial, que tengas un gran  día!"
