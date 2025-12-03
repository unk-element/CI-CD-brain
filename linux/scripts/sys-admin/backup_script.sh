#!/bin/bash

#############################################
# Script de Backup Incremental
# Autor: Admin
# Descripción: Realiza backups con rotación
#############################################

# Configuración
BACKUP_SOURCE="/home/usuario/datos"
BACKUP_DEST="/backup"
RETENTION_DAYS=7
LOG_FILE="/var/log/backup.log"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}.tar.gz"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función para mostrar errores
error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

# Función para mostrar éxito
success() {
    echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOG_FILE"
}

# Verificar que el script se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   error "Este script debe ejecutarse como root"
fi

# Verificar que existe el directorio origen
if [ ! -d "$BACKUP_SOURCE" ]; then
    error "El directorio origen no existe: $BACKUP_SOURCE"
fi

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DEST" || error "No se pudo crear el directorio de backup"

log "=== Iniciando backup ==="
log "Origen: $BACKUP_SOURCE"
log "Destino: $BACKUP_DEST/$BACKUP_NAME"

# Realizar el backup
tar -czf "$BACKUP_DEST/$BACKUP_NAME" "$BACKUP_SOURCE" 2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DEST/$BACKUP_NAME" | cut -f1)
    success "Backup completado exitosamente. Tamaño: $BACKUP_SIZE"
else
    error "Falló la creación del backup"
fi

# Eliminar backups antiguos (más de X días)
log "Limpiando backups antiguos (más de $RETENTION_DAYS días)..."
find "$BACKUP_DEST" -name "backup_*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
DELETED=$?

if [ $DELETED -eq 0 ]; then
    success "Limpieza completada"
fi

# Mostrar backups existentes
log "Backups disponibles:"
ls -lh "$BACKUP_DEST"/backup_*.tar.gz | awk '{print $9, "-", $5}' | tee -a "$LOG_FILE"

# Calcular espacio disponible
AVAILABLE_SPACE=$(df -h "$BACKUP_DEST" | awk 'NR==2 {print $4}')
log "Espacio disponible en $BACKUP_DEST: $AVAILABLE_SPACE"

log "=== Backup finalizado ==="