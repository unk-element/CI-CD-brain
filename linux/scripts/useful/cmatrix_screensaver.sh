#!/bin/bash

# Script para lanzar cmatrix después de 30 segundos de inactividad
# Autor: Script de salvapantallas para terminal

# Configuración
TIMEOUT=20 # Segundos de inactividad antes de lanzar cmatrix
CMATRIX_OPTS="-u 5 -s -C white"

# Función para limpiar al salir
cleanup() {
    tput cnorm  # Restaurar cursor
    stty echo   # Restaurar echo
    exit 0
}

# Capturar señales de salida
trap cleanup SIGINT SIGTERM EXIT

echo "Monitor de inactividad iniciado (${TIMEOUT}s)"
echo "Presiona Ctrl+C para salir"
echo ""

# Variables de control
last_activity=$(date +%s)
screensaver_active=false

# Función para detectar actividad
check_activity() {
    # Leer con timeout
    if read -t 0.1 -n 1 key 2>/dev/null; then
        return 0  # Hay actividad
    fi
    return 1  # No hay actividad
}

# Bucle principal
while true; do
    current_time=$(date +%s)
    idle_time=$((current_time - last_activity))
    
    # Verificar si hay actividad
    if check_activity; then
        last_activity=$(date +%s)
        
        # Si el salvapantallas está activo, detenerlo
        if [ "$screensaver_active" = true ]; then
            # Matar cmatrix si está ejecutándose
            pkill -P $$ cmatrix 2>/dev/null
            clear
            screensaver_active=false
            echo "Monitor de inactividad iniciado (${TIMEOUT}s)"
            echo "Presiona Ctrl+C para salir"
            echo ""
        fi
    fi
    
    # Si ha pasado el tiempo de inactividad y no está activo el salvapantallas
    if [ $idle_time -ge $TIMEOUT ] && [ "$screensaver_active" = false ]; then
        clear
        echo "Iniciando cmatrix... (presiona cualquier tecla para salir)"
        sleep 1
        screensaver_active=true
        
        # Lanzar cmatrix
        cmatrix $CMATRIX_OPTS &
        cmatrix_pid=$!
        
        # Esperar a que se presione una tecla
        while [ "$screensaver_active" = true ]; do
            if check_activity; then
                kill $cmatrix_pid 2>/dev/null
                wait $cmatrix_pid 2>/dev/null
                clear
                screensaver_active=false
                last_activity=$(date +%s)
                echo "Monitor de inactividad iniciado (${TIMEOUT}s)"
                echo "Presiona Ctrl+C para salir"
                echo ""
            fi
            sleep 0.1
        done
    fi
    
    sleep 0.1
done
