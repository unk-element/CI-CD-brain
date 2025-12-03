#!/bin/bash

# Script de actualización completa para Fedora
# (s/n)
echo "Up"
read respuesta
if [ "$respuesta" = "y" ] || [ "$respuesta" = "Y" ]; then

# Colores para output
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # Sin color

# Banner
echo -e "${AZUL}=========================================="
echo "  Script de Actualización de Fedora"
echo "==========================================${NC}"
echo ""


# Verificar si se ejecuta como root o con sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${ROJO}Este script necesita permisos de superusuario${NC}"
    echo "Ejecuta: sudo $0"
    exit 1
fi

# Función para mostrar mensajes
mensaje() {
    echo -e "${VERDE}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${ROJO}[ERROR]${NC} $1"
}


# 1. Actualizar repositorios y paquetes
echo ""
mensaje "Actualizando lista de repositorios..."
dnf check-update

echo ""
mensaje "Actualizando todos los paquetes del sistema..."
dnf upgrade -y

if [ $? -eq 0 ]; then
    mensaje "✓ Paquetes actualizados correctamente"
else
    error "Hubo un problema al actualizar los paquetes"
fi

# 2. Limpiar paquetes huérfanos
echo ""
mensaje "Eliminando paquetes innecesarios (autoremove)..."
dnf autoremove -y

if [ $? -eq 0 ]; then
    mensaje "✓ Paquetes innecesarios eliminados"
else
    error "Hubo un problema al eliminar paquetes"
fi

# 3. Limpiar caché
echo ""
mensaje "Limpiando caché de DNF..."
dnf clean all

if [ $? -eq 0 ]; then
    mensaje "✓ Caché limpiada correctamente"
else
    error "Hubo un problema al limpiar la caché"
fi

# 4. Verificar kernels antiguos (opcional)
echo ""
mensaje "Verificando kernels antiguos instalados..."
KERNELS=$(rpm -q kernel | wc -l)
if [ $KERNELS -gt 3 ]; then
    echo -e "${AMARILLO}Tienes $KERNELS kernels instalados. Se recomienda mantener solo 2-3.${NC}"
    echo "Para eliminar kernels antiguos manualmente, usa:"
    echo "  dnf remove --oldinstallonly"
fi

# 5. Actualizar Flatpak (si está instalado)
if command -v flatpak &> /dev/null; then
    echo ""
    mensaje "Actualizando aplicaciones Flatpak..."
    flatpak update -y
    if [ $? -eq 0 ]; then
        mensaje "✓ Flatpaks actualizados"
    fi
fi

# 6. Resumen final
echo ""
echo -e "${VERDE}=========================================="
echo "  ✓ Actualización completada"
echo "==========================================${NC}"
echo ""
echo "Resumen:"
echo "  • Paquetes actualizados"
echo "  • Paquetes innecesarios eliminados"
echo "  • Caché limpiada"
if command -v flatpak &> /dev/null; then
    echo "  • Flatpaks actualizados"
fi
echo ""

# Verificar si se requiere reinicio
if [ -f /var/run/reboot-required ]; then
    echo -e "${AMARILLO}⚠ Se recomienda reiniciar el sistema${NC}"
elif needs-restarting -r &> /dev/null; then
    if ! needs-restarting -r; then
        echo -e "${AMARILLO}⚠ Se recomienda reiniciar el sistema${NC}"
    fi
fi

echo ""
mensaje "¡Sistema actualizado correctamente!"
else
	echo "It's an illusion"
	exit 0
fi
