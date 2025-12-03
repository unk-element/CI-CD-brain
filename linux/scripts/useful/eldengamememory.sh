#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables del juego
PLAYER_HP=20
BOSS_HP=30
TURN=1

# Función para mostrar el estado
show_status() {
    echo -e "\n${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}           ${YELLOW}TURNO $TURN${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}Player HP:${NC} $PLAYER_HP ❤️                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${RED}Boss HP:${NC}   $BOSS_HP ❤️                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}\n"
}

# Función para elegir acción del Boss
boss_action() {
    # Boss elige aleatoriamente entre 1, 3 o 5
    local options=(1 3 5)
    local choice=${options[$RANDOM % 3]}
    echo $choice
    return 0
}

# Función para mostrar las opciones del jugador
show_player_options() {
    echo -e "${BLUE}Memoriza el ataque del Boss y elige tu acción:${NC}"
    echo -e "  ${GREEN}2${NC} - Parry    (Bloquea Fast Attack y duerme al boss)"
    echo -e "  ${GREEN}4${NC} - Attack   (Ataca al boss)"
    echo -e "  ${GREEN}6${NC} - Dodge    (Esquiva cualquier ataque)"
    echo ""
}

# Función para resolver el turno
resolve_turn() {
    local boss_move=$1
    local player_move=$2
    
    echo -e "\n${YELLOW}═══════════ RESOLUCIÓN ═══════════${NC}"
    
    # Mostrar movimientos
    case $boss_move in
        1) echo -e "${RED}Boss usa: Fast Attack ⚡${NC}" ;;
        3) echo -e "${RED}Boss usa: Regular Attack 🗡️${NC}" ;;
        5) echo -e "${RED}Boss usa: Heavy Attack 💥${NC}" ;;
    esac
    
    case $player_move in
        2) echo -e "${GREEN}Player usa: Parry 🛡️${NC}" ;;
        4) echo -e "${GREEN}Player usa: Attack ⚔️${NC}" ;;
        6) echo -e "${GREEN}Player usa: Dodge 🌀${NC}" ;;
    esac
    
    echo ""
    
    # Resolver interacciones
    if [ $player_move -eq 6 ]; then
        # Dodge esquiva todo
        echo -e "${CYAN}✨ ¡Esquivaste el ataque!${NC}"
        
    elif [ $player_move -eq 2 ]; then
        # Parry
        if [ $boss_move -eq 1 ]; then
            echo -e "${GREEN}🛡️  ¡Parry exitoso! Bloqueaste el Fast Attack${NC}"
            echo -e "${MAGENTA}💤 El Boss cae en un sueño profundo por 3 turnos${NC}"
            echo -e "${GREEN}   Durante ese tiempo pierde -6 HP total${NC}"
            BOSS_HP=$((BOSS_HP - 6))
            TURN=$((TURN + 3))
        else
            echo -e "${RED}💔 El Parry solo funciona contra Fast Attack${NC}"
            if [ $boss_move -eq 3 ]; then
                PLAYER_HP=$((PLAYER_HP - 2))
                echo -e "${RED}   Recibes -2 HP del Regular Attack${NC}"
            else
                PLAYER_HP=$((PLAYER_HP - 3))
                echo -e "${RED}   Recibes -3 HP del Heavy Attack${NC}"
            fi
        fi
        
    elif [ $player_move -eq 4 ]; then
        # Attack
        if [ $boss_move -eq 1 ]; then
            echo -e "${YELLOW}⚔️  Ambos atacan simultáneamente${NC}"
            PLAYER_HP=$((PLAYER_HP - 1))
            BOSS_HP=$((BOSS_HP - 2))
            echo -e "${RED}   Recibes -1 HP${NC}"
            echo -e "${GREEN}   Infliges -2 HP al Boss${NC}"
        elif [ $boss_move -eq 3 ]; then
            echo -e "${YELLOW}⚔️  Intercambio de golpes con Regular Attack${NC}"
            PLAYER_HP=$((PLAYER_HP - 2))
            BOSS_HP=$((BOSS_HP - 2))
            echo -e "${RED}   Recibes -2 HP${NC}"
            echo -e "${GREEN}   Infliges -2 HP al Boss${NC}"
        else
            echo -e "${GREEN}⚔️  ¡Tu ataque es más rápido que el Heavy Attack!${NC}"
            BOSS_HP=$((BOSS_HP - 2))
            echo -e "${GREEN}   Infliges -2 HP al Boss${NC}"
        fi
    fi
}

# Función principal del juego
game_loop() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║                                           ║"
    echo "║     JUEGO DE MEMORIA: PLAYER VS BOSS     ║"
    echo "║                                           ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}El Boss ataca primero. ¡Memoriza su movimiento!${NC}\n"
    sleep 2
    
    while [ $PLAYER_HP -gt 0 ] && [ $BOSS_HP -gt 0 ]; do
        show_status
        
        # Turno del Boss
        echo -e "${RED}═══ TURNO DEL BOSS ═══${NC}"
        boss_move=$(boss_action)
        
        # Generar operación matemática que resulte en el número del ataque
        echo -e "${RED}El Boss está calculando su ataque... 🎲${NC}"
        sleep 1
        
        # Generar operación aleatoria más difícil que dé como resultado boss_move
        case $boss_move in
            1)
                operations=(
                    "7 - 6"
                    "12 - 11"
                    "8 ÷ 8"
                    "15 - 14"
                    "9 - 8"
                    "3 × 2 - 5"
                    "10 ÷ 10"
                )
                ;;
            3)
                operations=(
                    "15 ÷ 5"
                    "7 + 3 - 12 + 5"
                    "1 × 3"
                    "20 - 11 / 3"
                    "6 ÷ 2"
                    "5 - 4 + 2"
                    "9 - 6"
                )
                ;;
            5)
                operations=(
                    "20 ÷ 4"
                    "15 - 10"
                    "2 + 3"
                    "25 ÷ 5"
                    "8 - 3"
                    "10 ÷ 2"
                    "3 + 4 - 2"
                )
                ;;
        esac
        
        random_op=${operations[$RANDOM % ${#operations[@]}]}
        echo -e "${YELLOW}¡Resuelve en 5 segundos!${NC}"
        echo -e "${CYAN}╔════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}   ${MAGENTA}$random_op = ?${NC}        ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════╝${NC}"
        sleep 5
        
        # Limpiar pantalla (simular memoria)
        clear
        show_status
        
        # Turno del Player
        echo -e "${GREEN}═══ TU TURNO ═══${NC}"
        show_player_options
        
        valid_input=false
        while [ "$valid_input" = false ]; do
            read -p "$(echo -e ${GREEN}Elige tu acción [2/4/6]: ${NC})" player_move
            
            if [[ "$player_move" =~ ^[246]$ ]]; then
                valid_input=true
            else
                echo -e "${RED}❌ Opción inválida. Elige 2, 4 o 6${NC}"
            fi
        done
        
        # Resolver turno
        resolve_turn $boss_move $player_move
        
        # Verificar victoria/derrota
        if [ $BOSS_HP -le 0 ]; then
            echo -e "\n${GREEN}╔═══════════════════════════════════╗${NC}"
            echo -e "${GREEN}║                                   ║${NC}"
            echo -e "${GREEN}║    🎉 ¡VICTORIA! 🎉              ║${NC}"
            echo -e "${GREEN}║    Derrotaste al Boss!           ║${NC}"
            echo -e "${GREEN}║                                   ║${NC}"
            echo -e "${GREEN}╚═══════════════════════════════════╝${NC}\n"
            break
        fi
        
        if [ $PLAYER_HP -le 0 ]; then
            echo -e "\n${RED}╔═══════════════════════════════════╗${NC}"
            echo -e "${RED}║                                   ║${NC}"
            echo -e "${RED}║    💀 GAME OVER 💀               ║${NC}"
            echo -e "${RED}║    El Boss te ha derrotado...    ║${NC}"
            echo -e "${RED}║                                   ║${NC}"
            echo -e "${RED}╚═══════════════════════════════════╝${NC}\n"
            break
        fi
        
        TURN=$((TURN + 1))
        echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
        read
        clear
    done
}

# Iniciar el juego
clear
game_loop

echo -e "${CYAN}Gracias por jugar!${NC}\n"
