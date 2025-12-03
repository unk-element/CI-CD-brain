#!/bin/bash

#############################################
# Parser de Logs del Sistema
# Analiza logs en busca de patrones
#############################################

LOG_FILE="${1:-/var/log/syslog}"
REPORT_FILE="/tmp/log_report_$(date +%Y%m%d).txt"

# Verificar que existe el archivo
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: No se encuentra el archivo $LOG_FILE"
    exit 1
fi

# Crear reporte
echo "================================================" > "$REPORT_FILE"
echo "REPORTE DE ANÁLISIS DE LOGS" >> "$REPORT_FILE"
echo "Archivo: $LOG_FILE" >> "$REPORT_FILE"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "================================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 1. Contar errores
echo "=== RESUMEN DE ERRORES ===" >> "$REPORT_FILE"
ERROR_COUNT=$(grep -i "error" "$LOG_FILE" | wc -l)
WARNING_COUNT=$(grep -i "warning" "$LOG_FILE" | wc -l)
FAILED_COUNT=$(grep -i "failed" "$LOG_FILE" | wc -l)

echo "Total de errores: $ERROR_COUNT" >> "$REPORT_FILE"
echo "Total de warnings: $WARNING_COUNT" >> "$REPORT_FILE"
echo "Total de fallos: $FAILED_COUNT" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. Top 10 errores más frecuentes
echo "=== TOP 10 ERRORES MÁS FRECUENTES ===" >> "$REPORT_FILE"
grep -i "error" "$LOG_FILE" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' | \
    sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 3. Intentos de autenticación fallidos (SSH)
echo "=== INTENTOS SSH FALLIDOS ===" >> "$REPORT_FILE"
SSH_FAILED=$(grep -i "failed password" "$LOG_FILE" | wc -l)
echo "Total de intentos fallidos: $SSH_FAILED" >> "$REPORT_FILE"

if [ $SSH_FAILED -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "IPs con más intentos:" >> "$REPORT_FILE"
    grep -i "failed password" "$LOG_FILE" | \
        grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | \
        sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 4. Servicios reiniciados
echo "=== SERVICIOS REINICIADOS ===" >> "$REPORT_FILE"
grep -iE "start|restart|stop" "$LOG_FILE" | \
    grep -i "service" | tail -20 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 5. Uso de disco crítico
echo "=== ALERTAS DE DISCO ===" >> "$REPORT_FILE"
grep -iE "disk|space|full" "$LOG_FILE" | tail -10 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 6. Estadísticas por hora
echo "=== ACTIVIDAD POR HORA ===" >> "$REPORT_FILE"
awk '{print $3}' "$LOG_FILE" | cut -d: -f1 | sort | uniq -c | sort -k2 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Mostrar el reporte en pantalla
cat "$REPORT_FILE"

# Enviar alerta si hay muchos errores
if [ $ERROR_COUNT -gt 100 ]; then
    echo ""
    echo "⚠️  ALERTA: Se detectaron más de 100 errores en el log"
fi

echo ""
echo "Reporte guardado en: $REPORT_FILE"