#!/bin/bash

#############################################
# Sistema de Monitoreo Avanzado
# Monitorea CPU, RAM, Disco y envía alertas
#############################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuración
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="/var/log/monitoring"
readonly LOG_FILE="${LOG_DIR}/system_monitor.log"
readonly ALERT_LOG="${LOG_DIR}/alerts.log"
readonly PID_FILE="/var/run/system_monitor.pid"

# Umbrales de alerta
readonly CPU_THRESHOLD=80
readonly MEM_THRESHOLD=85
readonly DISK_THRESHOLD=90
readonly LOAD_THRESHOLD=4.0

# Email para alertas (opcional)
readonly ADMIN_EMAIL="admin@example.com"
readonly ENABLE_EMAIL_ALERTS=false

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

#############################################
# Funciones de Logging
#############################################

setup_logging() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE" "$ALERT_LOG"
}

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_alert() {
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ALERT: ${message}" | tee -a "$ALERT_LOG"
    log_warn "$message"
}

#############################################
# Manejo de Errores
#############################################

error_exit() {
    log_error "$1"
    cleanup
    exit 1
}

cleanup() {
    log_info "Limpiando recursos..."
    [[ -f "$PID_FILE" ]] && rm -f "$PID_FILE"
}

trap cleanup EXIT
trap 'error_exit "Script interrumpido por señal"' INT TERM

#############################################
# Verificaciones del Sistema
#############################################

check_dependencies() {
    local deps=("awk" "grep" "bc" "df" "free" "top")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "Dependencia no encontrada: $cmd"
        fi
    done
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "Este script debe ejecutarse como root"
    fi
}

check_already_running() {
    if [[ -f "$PID_FILE" ]]; then
        local old_pid
        old_pid=$(cat "$PID_FILE")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            error_exit "El script ya está en ejecución (PID: $old_pid)"
        else
            log_warn "Archivo PID obsoleto encontrado, eliminando..."
            rm -f "$PID_FILE"
        fi
    fi
    echo $$ > "$PID_FILE"
}

#############################################
# Funciones de Monitoreo
#############################################

get_cpu_usage() {
    top -bn2 -d 0.5 | grep "Cpu(s)" | tail -1 | awk '{print $2}' | cut -d'%' -f1
}

get_memory_usage() {
    free | awk '/Mem:/ {printf "%.0f", ($3/$2) * 100}'
}

get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'
}

get_swap_usage() {
    free | awk '/Swap:/ {if ($2 > 0) printf "%.0f", ($3/$2) * 100; else print "0"}'
}

#############################################
# Sistema de Alertas
#############################################

send_alert() {
    local subject="$1"
    local message="$2"
    
    log_alert "$subject: $message"
    
    if [[ "$ENABLE_EMAIL_ALERTS" == "true" ]]; then
        echo "$message" | mail -s "$subject" "$ADMIN_EMAIL" 2>/dev/null || \
            log_error "No se pudo enviar el email de alerta"
    fi
}

check_cpu_alert() {
    local cpu_usage="$1"
    local cpu_int=${cpu_usage%.*}
    
    if (( cpu_int >= CPU_THRESHOLD )); then
        send_alert "ALERTA: Uso de CPU alto" \
            "Uso de CPU: ${cpu_usage}% (umbral: ${CPU_THRESHOLD}%)"
        
        # Listar procesos que más CPU usan
        log_info "Top 5 procesos por CPU:"
        ps aux --sort=-%cpu | head -6 | tail -5 | tee -a "$LOG_FILE"
    fi
}

check_memory_alert() {
    local mem_usage="$1"
    
    if (( mem_usage >= MEM_THRESHOLD )); then
        send_alert "ALERTA: Uso de memoria alto" \
            "Uso de memoria: ${mem_usage}% (umbral: ${MEM_THRESHOLD}%)"
        
        # Listar procesos que más memoria usan
        log_info "Top 5 procesos por memoria:"
        ps aux --sort=-%mem | head -6 | tail -5 | tee -a "$LOG_FILE"
    fi
}

check_disk_alert() {
    local disk_usage="$1"
    
    if (( disk_usage >= DISK_THRESHOLD )); then
        send_alert "ALERTA: Espacio en disco bajo" \
            "Uso de disco: ${disk_usage}% (umbral: ${DISK_THRESHOLD}%)"
        
        # Mostrar directorios más grandes
        log_info "Directorios más grandes en /:"
        du -h --max-depth=1 / 2>/dev/null | sort -rh | head -10 | tee -a "$LOG_FILE"
    fi
}

check_load_alert() {
    local load="$1"
    local load_comparison
    load_comparison=$(echo "$load >= $LOAD_THRESHOLD" | bc -l)
    
    if (( load_comparison )); then
        send_alert "ALERTA: Carga del sistema alta" \
            "Load average: ${load} (umbral: ${LOAD_THRESHOLD})"
    fi
}

#############################################
# Función Principal de Monitoreo
#############################################

monitor_system() {
    log_info "========== Iniciando ciclo de monitoreo =========="
    
    # Obtener métricas
    local cpu_usage mem_usage disk_usage load_avg swap_usage
    
    cpu_usage=$(get_cpu_usage)
    mem_usage=$(get_memory_usage)
    disk_usage=$(get_disk_usage)
    load_avg=$(get_load_average)
    swap_usage=$(get_swap_usage)
    
    # Registrar métricas
    log_info "CPU: ${cpu_usage}% | MEM: ${mem_usage}% | DISK: ${disk_usage}% | LOAD: ${load_avg} | SWAP: ${swap_usage}%"
    
    # Verificar umbrales
    check_cpu_alert "$cpu_usage"
    check_memory_alert "$mem_usage"
    check_disk_alert "$disk_usage"
    check_load_alert "$load_avg"
    
    # Estado de servicios críticos
    check_critical_services
    
    log_info "========== Ciclo de monitoreo completado =========="
    echo ""
}

check_critical_services() {
    local critical_services=("ssh" "cron")
    
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_info "Servicio $service: OK"
        else
            send_alert "ALERTA: Servicio crítico inactivo" \
                "El servicio $service no está activo"
        fi
    done
}

#############################################
# Modo Continuo
#############################################

run_continuous() {
    local interval="${1:-60}"  # Default: 60 segundos
    
    log_info "Iniciando monitoreo continuo (intervalo: ${interval}s)"
    log_info "Presiona Ctrl+C para detener"
    
    while true; do
        monitor_system
        sleep "$interval"
    done
}

#############################################
# Función de Ayuda
#############################################

show_usage() {
    cat << EOF
Uso: $0 [OPCIONES]

Opciones:
    -c, --continuous [INTERVAL]   Ejecutar en modo continuo (default: 60s)
    -o, --once                    Ejecutar una sola vez
    -s, --status                  Mostrar estado actual sin alertas
    -h, --help                    Mostrar esta ayuda

Ejemplos:
    $0 --once                     # Ejecutar una vez
    $0 --continuous 30            # Monitorear cada 30 segundos
    $0 --continuous               # Monitorear cada 60 segundos

EOF
}

show_status() {
    echo -e "${GREEN}=== Estado del Sistema ===${NC}"
    echo ""
    echo "CPU: $(get_cpu_usage)%"
    echo "Memoria: $(get_memory_usage)%"
    echo "Disco: $(get_disk_usage)%"
    echo "Load Average: $(get_load_average)"
    echo "Swap: $(get_swap_usage)%"
}

#############################################
# Main
#############################################

main() {
    setup_logging
    check_dependencies
    check_root
    
    case "${1:-}" in
        -c|--continuous)
            check_already_running
            run_continuous "${2:-60}"
            ;;
        -o|--once)
            monitor_system
            ;;
        -s|--status)
            show_status
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"