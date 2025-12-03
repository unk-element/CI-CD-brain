#!/bin/bash

#############################################
# Menú Interactivo de Administración
# Centraliza tareas comunes del sistema
#############################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para limpiar pantalla y mostrar header
show_header() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}     MENÚ DE ADMINISTRACIÓN DEL SISTEMA${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

# Función para pausar
pause() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}

# 1. Información del sistema
show_system_info() {
    show_header
    echo -e "${GREEN}=== INFORMACIÓN DEL SISTEMA ===${NC}"
    echo ""
    
    echo "Hostname: $(hostname)"
    echo "Sistema Operativo: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Arquitectura: $(uname -m)"
    echo ""
    
    echo "Uptime: $(uptime -p)"
    echo "Carga del sistema: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    
    echo "CPU:"
    lscpu | grep "Model name" | cut -d: -f2 | xargs
    echo "Núcleos: $(nproc)"
    echo ""
    
    echo "Memoria Total: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Memoria Usada: $(free -h | awk '/^Mem:/ {print $3}')"
    echo "Memoria Libre: $(free -h | awk '/^Mem:/ {print $4}')"
    
    pause
}

# 2. Estado de servicios
check_services() {
    show_header
    echo -e "${GREEN}=== ESTADO DE SERVICIOS PRINCIPALES ===${NC}"
    echo ""
    
    services=("ssh" "nginx" "apache2" "mysql" "postgresql" "docker")
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            status=$(systemctl is-active "$service" 2>/dev/null)
            if [ "$status" == "active" ]; then
                echo -e "✓ $service: ${GREEN}Activo${NC}"
            else
                echo -e "✗ $service: ${RED}Inactivo${NC}"
            fi
        fi
    done
    
    pause
}

# 3. Uso de disco
disk_usage() {
    show_header
    echo -e "${GREEN}=== USO DE DISCO ===${NC}"
    echo ""
    
    df -h | grep -v "tmpfs" | grep -v "udev"
    echo ""
    
    echo -e "${YELLOW}Top 10 directorios más grandes:${NC}"
    du -h --max-depth=1 /home 2>/dev/null | sort -rh | head -10
    
    pause
}

# 4. Procesos activos
top_processes() {
    show_header
    echo -e "${GREEN}=== PROCESOS CON MÁS USO DE CPU ===${NC}"
    echo ""
    
    ps aux --sort=-%cpu | head -11
    echo ""
    
    echo -e "${GREEN}=== PROCESOS CON MÁS USO DE MEMORIA ===${NC}"
    echo ""
    ps aux --sort=-%mem | head -11
    
    pause
}

# 5. Usuarios conectados
active_users() {
    show_header
    echo -e "${GREEN}=== USUARIOS CONECTADOS ===${NC}"
    echo ""
    
    who
    echo ""
    
    echo "Total de sesiones: $(who | wc -l)"
    echo ""
    
    echo -e "${GREEN}=== ÚLTIMOS LOGINS ===${NC}"
    last -n 10
    
    pause
}

# 6. Red
network_info() {
    show_header
    echo -e "${GREEN}=== INFORMACIÓN DE RED ===${NC}"
    echo ""
    
    echo "Interfaces de red:"
    ip -brief addr show
    echo ""
    
    echo "Puertos escuchando:"
    ss -tuln | grep LISTEN | head -10
    echo ""
    
    echo "Conexiones activas:"
    ss -tu | grep ESTAB | wc -l
    
    pause
}

# 7. Logs recientes
recent_logs() {
    show_header
    echo -e "${GREEN}=== LOGS RECIENTES ===${NC}"
    echo ""
    
    echo -e "${YELLOW}Últimos errores del sistema:${NC}"
    journalctl -p err -n 10 --no-pager
    
    pause
}

# 8. Gestionar servicios
manage_services() {
    show_header
    echo -e "${GREEN}=== GESTIÓN DE SERVICIOS ===${NC}"
    echo ""
    
    read -p "Nombre del servicio: " service_name
    echo ""
    echo "1. Iniciar"
    echo "2. Detener"
    echo "3. Reiniciar"
    echo "4. Ver estado"
    echo "5. Ver logs"
    echo ""
    read -p "Selecciona una opción: " service_action
    
    case $service_action in
        1)
            sudo systemctl start "$service_name"
            echo -e "${GREEN}Servicio iniciado${NC}"
            ;;
        2)
            sudo systemctl stop "$service_name"
            echo -e "${YELLOW}Servicio detenido${NC}"
            ;;
        3)
            sudo systemctl restart "$service_name"
            echo -e "${GREEN}Servicio reiniciado${NC}"
            ;;
        4)
            systemctl status "$service_name"
            ;;
        5)
            journalctl -u "$service_name" -n 50 --no-pager
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            ;;
    esac
    
    pause
}

# Menú principal
main_menu() {
    while true; do
        show_header
        echo "1.  Información del sistema"
        echo "2.  Estado de servicios"
        echo "3.  Uso de disco"
        echo "4.  Procesos activos"
        echo "5.  Usuarios conectados"
        echo "6.  Información de red"
        echo "7.  Logs recientes"
        echo "8.  Gestionar servicios"
        echo "9.  Salir"
        echo ""
        read -p "Selecciona una opción [1-9]: " option
        
        case $option in
            1) show_system_info ;;
            2) check_services ;;
            3) disk_usage ;;
            4) top_processes ;;
            5) active_users ;;
            6) network_info ;;
            7) recent_logs ;;
            8) manage_services ;;
            9) 
                echo -e "${GREEN}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                sleep 2
                ;;
        esac
    done
}

# Verificar que se ejecuta como root para ciertas operaciones
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Advertencia: Algunas funciones requieren permisos de root${NC}"
   sleep 2
fi

# Iniciar menú
main_menu