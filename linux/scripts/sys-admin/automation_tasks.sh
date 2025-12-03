#!/bin/bash

#############################################
# Automatización de Tareas Administrativas
# Limpieza, actualizaciones, mantenimiento
#############################################

set -euo pipefail

# Configuración
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_DIR="/var/log/automation"
readonly LOG_FILE="${LOG_DIR}/automation_$(date +%Y%m%d).log"
readonly LOCK_FILE="/var/run/${SCRIPT_NAME}.lock"
readonly MAX_LOG_SIZE=10485760  # 10MB
readonly LOG_RETENTION_DAYS=30
readonly TEMP_CLEANUP_DAYS=7

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Contadores de tareas
TASKS_SUCCESS=0
TASKS_FAILED=0
TASKS_SKIPPED=0

#############################################
# Sistema de Logging Avanzado
#############################################

setup_logging() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" || {
            echo "ERROR: No se pudo crear el directorio de logs" >&2
            exit 1
        }
    fi
    
    # Rotar log si es muy grande
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null) -gt $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
    fi
    
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
}

log_header() {
    local msg="$1"
    echo ""
    echo "=========================================="
    echo "  $msg"
    echo "=========================================="
}

log_task() {
    local status="$1"
    local task_name="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$status" in
        START)
            echo -e "${BLUE}[${timestamp}] ▶ Iniciando: ${task_name}${NC}"
            ;;
        SUCCESS)
            echo -e "${GREEN}[${timestamp}] ✓ Completado: ${task_name}${NC}"
            ((TASKS_SUCCESS++))
            ;;
        FAILED)
            echo -e "${RED}[${timestamp}] ✗ Falló: ${task_name}${NC}"
            ((TASKS_FAILED++))
            ;;
        SKIP)
            echo -e "${YELLOW}[${timestamp}] ⊘ Omitido: ${task_name}${NC}"
            ((TASKS_SKIPPED++))
            ;;
    esac
}

#############################################
# Control de Ejecución
#############################################

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "ERROR: Script ya está ejecutándose (PID: $pid)" >&2
            exit 1
        else
            echo "WARN: Eliminando archivo de bloqueo obsoleto"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

cleanup_on_exit() {
    release_lock
    show_summary
}

trap cleanup_on_exit EXIT
trap 'echo "Script interrumpido"; exit 130' INT TERM

#############################################
# Funciones de Validación
#############################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: Este script debe ejecutarse como root" >&2
        exit 1
    fi
}

validate_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_task SKIP "Comando no disponible: $cmd"
        return 1
    fi
    return 0
}

#############################################
# Tareas de Limpieza
#############################################

cleanup_temp_files() {
    log_task START "Limpieza de archivos temporales"
    
    local dirs_to_clean=("/tmp" "/var/tmp")
    local total_freed=0
    
    for dir in "${dirs_to_clean[@]}"; do
        if [[ -d "$dir" ]]; then
            local size_before
            size_before=$(du -sb "$dir" 2>/dev/null | awk '{print $1}')
            
            # Eliminar archivos más antiguos que TEMP_CLEANUP_DAYS
            find "$dir" -type f -mtime +${TEMP_CLEANUP_DAYS} -delete 2>/dev/null || true
            
            local size_after
            size_after=$(du -sb "$dir" 2>/dev/null | awk '{print $1}')
            local freed=$((size_before - size_after))
            total_freed=$((total_freed + freed))
            
            echo "  Limpiados en $dir: $(numfmt --to=iec $freed 2>/dev/null || echo "${freed} bytes")"
        fi
    done
    
    echo "  Total liberado: $(numfmt --to=iec $total_freed 2>/dev/null || echo "${total_freed} bytes")"
    log_task SUCCESS "Limpieza de archivos temporales"
}

cleanup_old_logs() {
    log_task START "Limpieza de logs antiguos"
    
    local log_dirs=("/var/log" "$LOG_DIR")
    local count=0
    
    for log_dir in "${log_dirs[@]}"; do
        if [[ -d "$log_dir" ]]; then
            count=$(find "$log_dir" -name "*.log" -type f -mtime +${LOG_RETENTION_DAYS} | wc -l)
            find "$log_dir" -name "*.log" -type f -mtime +${LOG_RETENTION_DAYS} -delete 2>/dev/null || true
            find "$log_dir" -name "*.log.*" -type f -mtime +${LOG_RETENTION_DAYS} -delete 2>/dev/null || true
        fi
    done
    
    echo "  Logs eliminados: $count archivos"
    log_task SUCCESS "Limpieza de logs antiguos"
}

cleanup_package_cache() {
    log_task START "Limpieza de caché de paquetes"
    
    if validate_command apt-get; then
        apt-get clean
        apt-get autoclean
        apt-get autoremove -y
        echo "  Caché APT limpiado"
    fi
    
    if validate_command yum; then
        yum clean all
        echo "  Caché YUM limpiado"
    fi
    
    if validate_command dnf; then
        dnf clean all
        echo "  Caché DNF limpiado"
    fi
    
    log_task SUCCESS "Limpieza de caché de paquetes"
}

cleanup_journal() {
    log_task START "Limpieza de journald"
    
    if validate_command journalctl; then
        # Mantener solo últimos 7 días
        journalctl --vacuum-time=7d
        # O limitar por tamaño: journalctl --vacuum-size=500M
        log_task SUCCESS "Limpieza de journald"
    else
        log_task SKIP "journalctl no disponible"
    fi
}

#############################################
# Tareas de Mantenimiento
#############################################

rotate_logs() {
    log_task START "Rotación de logs"
    
    if validate_command logrotate; then
        logrotate -f /etc/logrotate.conf 2>/dev/null || {
            echo "  WARN: Algunos logs no pudieron rotarse"
        }
        log_task SUCCESS "Rotación de logs"
    else
        log_task SKIP "logrotate no disponible"
    fi
}

check_disk_space() {
    log_task START "Verificación de espacio en disco"
    
    local critical=false
    
    df -h | grep -v "tmpfs\|devtmpfs\|udev" | awk 'NR>1 {print $5, $6}' | while read usage mount; do
        usage_num=${usage%\%}
        echo "  $mount: $usage"
        
        if [[ $usage_num -ge 90 ]]; then
            echo "  ⚠️  CRÍTICO: $mount está al $usage"
            critical=true
        elif [[ $usage_num -ge 80 ]]; then
            echo "  ⚠️  ADVERTENCIA: $mount está al $usage"
        fi
    done
    
    log_task SUCCESS "Verificación de espacio en disco"
}

optimize_databases() {
    log_task START "Optimización de bases de datos"
    
    # MySQL/MariaDB
    if validate_command mysqlcheck && systemctl is-active mysql >/dev/null 2>&1; then
        mysqlcheck --optimize --all-databases 2>/dev/null || {
            echo "  WARN: No se pudo optimizar MySQL (¿credenciales?)"
        }
    fi
    
    # PostgreSQL
    if validate_command vacuumdb && systemctl is-active postgresql >/dev/null 2>&1; then
        sudo -u postgres vacuumdb --all 2>/dev/null || {
            echo "  WARN: No se pudo optimizar PostgreSQL"
        }
    fi
    
    log_task SUCCESS "Optimización de bases de datos"
}

update_locate_database() {
    log_task START "Actualización de base de datos locate"
    
    if validate_command updatedb; then
        updatedb
        log_task SUCCESS "Actualización de base de datos locate"
    else
        log_task SKIP "updatedb no disponible"
    fi
}

check_broken_symlinks() {
    log_task START "Búsqueda de enlaces simbólicos rotos"
    
    local common_dirs=("/usr/local" "/opt" "/home")
    local broken_count=0
    
    for dir in "${common_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r link; do
                echo "  Enlace roto: $link"
                ((broken_count++))
            done < <(find "$dir" -xtype l 2>/dev/null)
        fi
    done
    
    echo "  Total de enlaces rotos encontrados: $broken_count"
    log_task SUCCESS "Búsqueda de enlaces simbólicos rotos"
}

#############################################
# Tareas de Seguridad
#############################################

check_failed_logins() {
    log_task START "Verificación de intentos de login fallidos"
    
    if [[ -f /var/log/auth.log ]]; then
        local failed_count
        failed_count=$(grep "Failed password" /var/log/auth.log | wc -l)
        echo "  Intentos fallidos en auth.log: $failed_count"
        
        if [[ $failed_count -gt 10 ]]; then
            echo "  ⚠️  IPs con más intentos:"
            grep "Failed password" /var/log/auth.log | \
                grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | \
                sort | uniq -c | sort -rn | head -5
        fi
    fi
    
    log_task SUCCESS "Verificación de intentos de login fallidos"
}

check_world_writable() {
    log_task START "Búsqueda de archivos con permisos inseguros"
    
    local dangerous_dirs=("/etc" "/usr/local" "/opt")
    local count=0
    
    for dir in "${dangerous_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r file; do
                echo "  ⚠️  World-writable: $file"
                ((count++))
            done < <(find "$dir" -type f -perm -002 2>/dev/null | head -10)
        fi
    done
    
    echo "  Archivos con permisos inseguros: $count (mostrando primeros 10)"
    log_task SUCCESS "Búsqueda de archivos con permisos inseguros"
}

#############################################
# Resumen Final
#############################################

show_summary() {
    echo ""
    log_header "RESUMEN DE EJECUCIÓN"
    echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "${GREEN}Tareas exitosas:  $TASKS_SUCCESS${NC}"
    echo -e "${RED}Tareas fallidas:   $TASKS_FAILED${NC}"
    echo -e "${YELLOW}Tareas omitidas:   $TASKS_SKIPPED${NC}"
    echo ""
    echo "Log guardado en: $LOG_FILE"
}

#############################################
# Menú de Tareas
#############################################

show_menu() {
    cat << EOF
Tareas disponibles:
  1. Limpieza completa (temp files, logs, cache)
  2. Mantenimiento (rotación logs, optimizar DB)
  3. Verificaciones de seguridad
  4. Todas las tareas
  5. Personalizada

EOF
}

run_all_tasks() {
    log_header "INICIANDO AUTOMATIZACIÓN COMPLETA"
    
    # Limpieza
    cleanup_temp_files
    cleanup_old_logs
    cleanup_package_cache
    cleanup_journal
    
    # Mantenimiento
    rotate_logs
    check_disk_space
    optimize_databases
    update_locate_database
    check_broken_symlinks
    
    # Seguridad
    check_failed_logins
    check_world_writable
}

#############################################
# Main
#############################################

main() {
    check_root
    setup_logging
    acquire_lock
    
    log_header "SCRIPT DE AUTOMATIZACIÓN DE TAREAS"
    
    case "${1:-all}" in
        clean)
            cleanup_temp_files
            cleanup_old_logs
            cleanup_package_cache
            cleanup_journal
            ;;
        maintenance)
            rotate_logs
            check_disk_space
            optimize_databases
            update_locate_database
            ;;
        security)
            check_failed_logins
            check_world_writable
            ;;
        all|*)
            run_all_tasks
            ;;
    esac
}

main "$@"