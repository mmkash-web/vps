#!/bin/bash

# EMMKASHTECH Modern VPS Menu System
# Compatible with Ubuntu 18.04, 20.04, 22.04, 24.04 LTS
# Advanced UI with real-time system monitoring

# Terminal compatibility check
if [[ $TERM != "xterm"* ]] && [[ $TERM != "screen"* ]] && [[ $TERM != "tmux"* ]]; then
    export TERM=xterm-256color
fi

# Color definitions for modern UI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly UNDERLINE='\033[4m'
readonly BLINK='\033[5m'
readonly REVERSE='\033[7m'
readonly NC='\033[0m' # No Color

# Modern gradient colors
readonly GRAD1='\033[38;5;81m'  # Bright Cyan
readonly GRAD2='\033[38;5;75m'  # Light Blue
readonly GRAD3='\033[38;5;69m'  # Medium Blue
readonly GRAD4='\033[38;5;63m'  # Blue Purple
readonly GRAD5='\033[38;5;57m'  # Purple

# Background colors
readonly BG_BLUE='\033[44m'
readonly BG_GREEN='\033[42m'
readonly BG_RED='\033[41m'

# System information functions
get_system_info() {
    # Get OS version with Ubuntu 24 support
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION"
        OS_ID="$ID"
        OS_VERSION_ID="$VERSION_ID"
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
        OS_ID="unknown"
        OS_VERSION_ID="unknown"
    fi
    
    # System stats
    HOSTNAME=$(hostname)
    KERNEL=$(uname -r)
    UPTIME=$(uptime -p | sed 's/up //')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | tr -d ',')
    
    # Memory info
    MEMORY=$(free -h | awk '/^Mem:/ { print $3"/"$2 }')
    MEMORY_PERCENT=$(free | awk '/^Mem:/ { printf("%.1f", $3/$2 * 100.0) }')
    
    # Disk usage
    DISK_USAGE=$(df -h / | awk 'NR==2 { print $3"/"$2" ("$5")" }')
    DISK_PERCENT=$(df / | awk 'NR==2 { print $5 }' | tr -d '%')
    
    # CPU info
    CPU_CORES=$(nproc)
    CPU_MODEL=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//')
    
    # Network info
    PUBLIC_IP=$(curl -s ipinfo.io/ip 2>/dev/null || echo "N/A")
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    
    # Service status
    SERVICES_STATUS=""
    check_service() {
        if systemctl is-active --quiet $1 2>/dev/null; then
            echo "${GREEN}●${NC}"
        else
            echo "${RED}●${NC}"
        fi
    }
}

# Modern banner with animation
show_banner() {
    clear
    
    # Terminal size detection
    COLS=$(tput cols)
    ROWS=$(tput lines)
    
    # Center calculation
    BANNER_WIDTH=70
    PADDING=$(( (COLS - BANNER_WIDTH) / 2 ))
    PAD_STRING=$(printf "%*s" $PADDING "")
    
    echo
    echo -e "${PAD_STRING}${GRAD1}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD2}                                                                      ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD2}    ███████ ███    ███ ███    ███ ██   ██  █████  ███████ ██   ██    ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD2}    ██      ████  ████ ████  ████ ██  ██  ██   ██ ██      ██   ██    ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD3}    █████   ██ ████ ██ ██ ████ ██ █████   ███████ ███████ ███████    ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD3}    ██      ██  ██  ██ ██  ██  ██ ██  ██  ██   ██      ██ ██   ██    ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD4}    ███████ ██      ██ ██      ██ ██   ██ ██   ██ ███████ ██   ██    ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD4}                                                                      ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD4}                        ████████ ███████  ██████ ██   ██            ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD5}                           ██    ██      ██      ██   ██            ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD5}                           ██    █████   ██      ███████            ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD5}                           ██    ██      ██      ██   ██            ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD5}                           ██    ███████  ██████ ██   ██            ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD5}                                                                      ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${WHITE}                     🚀 ${BOLD}PROFESSIONAL VPS MANAGEMENT SUITE${NC}${WHITE} 🚀                ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${CYAN}                        Advanced Multi-Protocol VPN System               ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}║${GRAD5}                                                                      ${GRAD1}║${NC}"
    echo -e "${PAD_STRING}${GRAD1}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# System info panel
show_system_info() {
    get_system_info
    
    local info_width=70
    local padding=$(( ($(tput cols) - info_width) / 2 ))
    local pad_string=$(printf "%*s" $padding "")
    
    echo -e "${pad_string}${BLUE}┌─────────────────────── ${WHITE}${BOLD}SYSTEM INFORMATION${NC}${BLUE} ───────────────────────┐${NC}"
    echo -e "${pad_string}${BLUE}│${NC} ${CYAN}🖥️  Server${NC}    : ${WHITE}$HOSTNAME${NC} ${BLUE}│${NC} ${CYAN}💾 Memory${NC}   : ${WHITE}$MEMORY${NC} ${BLUE}│${NC}"
    echo -e "${pad_string}${BLUE}│${NC} ${CYAN}🐧 OS${NC}         : ${WHITE}$OS_NAME $OS_VERSION${NC} ${BLUE}│${NC} ${CYAN}💿 Disk${NC}     : ${WHITE}$DISK_USAGE${NC} ${BLUE}│${NC}"
    echo -e "${pad_string}${BLUE}│${NC} ${CYAN}⚡ Kernel${NC}     : ${WHITE}$KERNEL${NC} ${BLUE}│${NC} ${CYAN}⏱️  Uptime${NC}   : ${WHITE}$UPTIME${NC} ${BLUE}│${NC}"
    echo -e "${pad_string}${BLUE}│${NC} ${CYAN}🌐 Public IP${NC}  : ${WHITE}$PUBLIC_IP${NC} ${BLUE}│${NC} ${CYAN}📡 Local IP${NC} : ${WHITE}$LOCAL_IP${NC} ${BLUE}│${NC}"
    echo -e "${pad_string}${BLUE}│${NC} ${CYAN}🔥 CPU Load${NC}   : ${WHITE}$LOAD${NC} ${BLUE}│${NC} ${CYAN}🧮 CPU Cores${NC}: ${WHITE}$CPU_CORES${NC} ${BLUE}│${NC}"
    echo -e "${pad_string}${BLUE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

# Service status indicator
show_service_status() {
    local padding=$(( ($(tput cols) - 70) / 2 ))
    local pad_string=$(printf "%*s" $padding "")
    
    echo -e "${pad_string}${PURPLE}┌──────────────────────── ${WHITE}${BOLD}SERVICES STATUS${NC}${PURPLE} ────────────────────────┐${NC}"
    echo -e "${pad_string}${PURPLE}│${NC}"
    printf "${pad_string}${PURPLE}│${NC} ${CYAN}SSH${NC}:$(check_service ssh) ${CYAN}OpenVPN${NC}:$(check_service openvpn) ${CYAN}Nginx${NC}:$(check_service nginx) ${CYAN}Xray${NC}:$(check_service xray)"
    printf " ${CYAN}WireGuard${NC}:$(check_service wg-quick@wg0) ${CYAN}Stunnel${NC}:$(check_service stunnel5) ${PURPLE}│${NC}\n"
    echo -e "${pad_string}${PURPLE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

# Modern menu options with icons
show_menu_options() {
    local padding=$(( ($(tput cols) - 80) / 2 ))
    local pad_string=$(printf "%*s" $padding "")
    
    echo -e "${pad_string}${YELLOW}╔════════════════════════════ ${WHITE}${BOLD}SERVICE MENU${NC}${YELLOW} ════════════════════════════╗${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}                                                                              ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD2}📶 ${WHITE}${BOLD}1.${NC}  SSH & OpenVPN Management      ${GRAD2}🔒 ${WHITE}${BOLD}8.${NC}  VMESS Protocol         ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD2}🔗 ${WHITE}${BOLD}2.${NC}  L2TP VPN Service             ${GRAD2}⚡ ${WHITE}${BOLD}9.${NC}  VLESS Protocol         ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD3}🌐 ${WHITE}${BOLD}3.${NC}  PPTP VPN Service             ${GRAD3}🗡️  ${WHITE}${BOLD}10.${NC} TROJAN GFW Protocol     ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD3}🔐 ${WHITE}${BOLD}4.${NC}  SSTP VPN Service             ${GRAD3}⚔️  ${WHITE}${BOLD}11.${NC} TROJAN GO Protocol      ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD4}🚀 ${WHITE}${BOLD}5.${NC}  WireGuard Modern VPN         ${GRAD4}⚙️  ${WHITE}${BOLD}12.${NC} System Settings         ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD4}👤 ${WHITE}${BOLD}6.${NC}  Shadowsocks Proxy            ${GRAD4}📊 ${WHITE}${BOLD}13.${NC} System Monitor          ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}  ${GRAD5}🎭 ${WHITE}${BOLD}7.${NC}  ShadowsocksR Enhanced        ${GRAD5}🚪 ${WHITE}${BOLD}14.${NC} Exit Menu               ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}║${NC}                                                                              ${YELLOW}║${NC}"
    echo -e "${pad_string}${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${pad_string}${WHITE}💡 ${CYAN}${BOLD}Quick Actions:${NC} ${WHITE}[R]efresh • [H]elp • [A]bout • [Q]uit${NC}"
    echo
}

# Enhanced input handling
get_user_input() {
    local padding=$(( ($(tput cols) - 60) / 2 ))
    local pad_string=$(printf "%*s" $padding "")
    
    echo -e "${pad_string}${GREEN}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${pad_string}${GREEN}│${NC} ${CYAN}${BOLD}Select your choice [1-14] or [R/H/A/Q]:${NC}                   ${GREEN}│${NC}"
    echo -e "${pad_string}${GREEN}└────────────────────────────────────────────────────────┘${NC}"
    echo -n "${pad_string}${WHITE}❯ ${NC}"
    read -r menu
}

# Help system
show_help() {
    clear
    show_banner
    local padding=$(( ($(tput cols) - 70) / 2 ))
    local pad_string=$(printf "%*s" $padding "")
    
    echo -e "${pad_string}${BLUE}╔════════════════════════ ${WHITE}${BOLD}HELP & GUIDE${NC}${BLUE} ════════════════════════╗${NC}"
    echo -e "${pad_string}${BLUE}║${NC}                                                                    ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${YELLOW}📖 Service Descriptions:${NC}                                        ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC}                                                                    ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${GREEN}• SSH & OpenVPN${NC}     - Traditional secure tunnel protocols       ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${GREEN}• L2TP/PPTP/SSTP${NC}    - Microsoft-compatible VPN protocols       ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${GREEN}• WireGuard${NC}         - Modern, fast, and secure VPN              ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${GREEN}• Shadowsocks/SSR${NC}   - High-performance proxy protocols          ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${GREEN}• VMESS/VLESS${NC}       - V2Ray next-generation protocols           ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${GREEN}• Trojan${NC}            - TLS-based stealth proxy protocols          ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC}                                                                    ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${YELLOW}🔧 Quick Tips:${NC}                                                  ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${CYAN}• Use Ctrl+C to interrupt any running process${NC}                   ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${CYAN}• Check service status before making changes${NC}                    ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC} ${CYAN}• Monitor system resources regularly${NC}                            ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}║${NC}                                                                    ${BLUE}║${NC}"
    echo -e "${pad_string}${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${pad_string}${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

# About information
show_about() {
    clear
    show_banner
    local padding=$(( ($(tput cols) - 70) / 2 ))
    local pad_string=$(printf "%*s" $padding "")
    
    echo -e "${pad_string}${PURPLE}╔══════════════════════ ${WHITE}${BOLD}ABOUT EMMKASHTECH${NC}${PURPLE} ══════════════════════╗${NC}"
    echo -e "${pad_string}${PURPLE}║${NC}                                                                    ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GRAD2}🏢 Company${NC}        : EMMKASHTECH Solutions                      ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GRAD2}📅 Version${NC}        : v2.0.0 Professional Edition               ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GRAD3}🐧 Compatibility${NC}  : Ubuntu 18.04, 20.04, 22.04, 24.04 LTS     ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GRAD3}🌐 Repository${NC}     : https://github.com/mmkash-web/vps         ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GRAD4}📧 Support${NC}        : support@emmkashtech.com                   ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GRAD4}📜 License${NC}        : Professional Use License                   ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC}                                                                    ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${YELLOW}⭐ Features:${NC}                                                  ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GREEN}✓${NC} Multi-protocol VPN support                                  ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GREEN}✓${NC} Real-time system monitoring                                 ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GREEN}✓${NC} Advanced security configurations                            ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GREEN}✓${NC} Automated certificate management                            ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC} ${GREEN}✓${NC} Professional technical support                              ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}║${NC}                                                                    ${PURPLE}║${NC}"
    echo -e "${pad_string}${PURPLE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${pad_string}${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

# System monitor
show_system_monitor() {
    while true; do
        clear
        show_banner
        
        local padding=$(( ($(tput cols) - 80) / 2 ))
        local pad_string=$(printf "%*s" $padding "")
        
        get_system_info
        
        echo -e "${pad_string}${GREEN}╔═══════════════════════ ${WHITE}${BOLD}LIVE SYSTEM MONITOR${NC}${GREEN} ═══════════════════════╗${NC}"
        echo -e "${pad_string}${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
        
        # Memory usage bar
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}💾 Memory Usage:${NC} ${WHITE}$MEMORY${NC} (${MEMORY_PERCENT}%)                                ${GREEN}║${NC}"
        local mem_bar=""
        for ((i=0; i<50; i++)); do
            if (( i < MEMORY_PERCENT / 2 )); then
                if (( MEMORY_PERCENT > 80 )); then
                    mem_bar+="${RED}█${NC}"
                elif (( MEMORY_PERCENT > 60 )); then
                    mem_bar+="${YELLOW}█${NC}"
                else
                    mem_bar+="${GREEN}█${NC}"
                fi
            else
                mem_bar+="${DIM}░${NC}"
            fi
        done
        echo -e "${pad_string}${GREEN}║${NC} $mem_bar ${GREEN}║${NC}"
        
        # Disk usage bar
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}💿 Disk Usage:${NC} ${WHITE}$DISK_USAGE${NC}                                        ${GREEN}║${NC}"
        local disk_bar=""
        for ((i=0; i<50; i++)); do
            if (( i < DISK_PERCENT / 2 )); then
                if (( DISK_PERCENT > 80 )); then
                    disk_bar+="${RED}█${NC}"
                elif (( DISK_PERCENT > 60 )); then
                    disk_bar+="${YELLOW}█${NC}"
                else
                    disk_bar+="${GREEN}█${NC}"
                fi
            else
                disk_bar+="${DIM}░${NC}"
            fi
        done
        echo -e "${pad_string}${GREEN}║${NC} $disk_bar ${GREEN}║${NC}"
        
        echo -e "${pad_string}${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}⚡ System Load:${NC} ${WHITE}$LOAD${NC}                                                    ${GREEN}║${NC}"
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}⏱️  Uptime:${NC} ${WHITE}$UPTIME${NC}                                                     ${GREEN}║${NC}"
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}🧮 CPU Cores:${NC} ${WHITE}$CPU_CORES${NC}                                                     ${GREEN}║${NC}"
        echo -e "${pad_string}${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
        
        # Network connections
        local connections=$(ss -tulpn | wc -l)
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}🌐 Network Connections:${NC} ${WHITE}$connections${NC}                                         ${GREEN}║${NC}"
        
        # Active users
        local active_users=$(who | wc -l)
        echo -e "${pad_string}${GREEN}║${NC} ${CYAN}👥 Active Users:${NC} ${WHITE}$active_users${NC}                                                 ${GREEN}║${NC}"
        
        echo -e "${pad_string}${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
        echo -e "${pad_string}${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        
        echo -e "${pad_string}${WHITE}Updates every 3 seconds. Press ${YELLOW}[Q]${NC}${WHITE} to quit, ${YELLOW}[R]${NC}${WHITE} to refresh now${NC}"
        
        # Non-blocking input check
        if read -t 3 -n 1 input; then
            case $input in
                [Qq])
                    break
                    ;;
                [Rr])
                    continue
                    ;;
            esac
        fi
    done
}

# Ubuntu version compatibility check
check_ubuntu_compatibility() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        
        case $VERSION_ID in
            "18.04"|"20.04"|"22.04"|"24.04")
                return 0
                ;;
            *)
                echo -e "${YELLOW}⚠️  Warning: Ubuntu $VERSION_ID may not be fully supported.${NC}"
                echo -e "${CYAN}Supported versions: 18.04, 20.04, 22.04, 24.04 LTS${NC}"
                echo -e "${WHITE}Continue anyway? [y/N]:${NC}"
                read -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
                ;;
        esac
    fi
}

# Main menu loop
main_menu() {
    # Check Ubuntu compatibility on startup
    check_ubuntu_compatibility
    
    while true; do
        clear
        show_banner
        show_system_info
        show_service_status
        show_menu_options
        get_user_input
        
        case $menu in
            1)
                clear
                echo -e "${GREEN}Loading SSH & OpenVPN Menu...${NC}"
                sshovpnmenu
                ;;
            2)
                clear
                echo -e "${GREEN}Loading L2TP Menu...${NC}"
                l2tpmenu
                ;;
            3)
                clear
                echo -e "${GREEN}Loading PPTP Menu...${NC}"
                pptpmenu
                ;;
            4)
                clear
                echo -e "${GREEN}Loading SSTP Menu...${NC}"
                sstpmenu
                ;;
            5)
                clear
                echo -e "${GREEN}Loading WireGuard Menu...${NC}"
                wgmenu
                ;;
            6)
                clear
                echo -e "${GREEN}Loading Shadowsocks Menu...${NC}"
                ssmenu
                ;;
            7)
                clear
                echo -e "${GREEN}Loading ShadowsocksR Menu...${NC}"
                ssrmenu
                ;;
            8)
                clear
                echo -e "${GREEN}Loading VMESS Menu...${NC}"
                vmessmenu
                ;;
            9)
                clear
                echo -e "${GREEN}Loading VLESS Menu...${NC}"
                vlessmenu
                ;;
            10)
                clear
                echo -e "${GREEN}Loading Trojan Menu...${NC}"
                trmenu
                ;;
            11)
                clear
                echo -e "${GREEN}Loading Trojan GO Menu...${NC}"
                trgomenu
                ;;
            12)
                clear
                echo -e "${GREEN}Loading Settings Menu...${NC}"
                setmenu
                ;;
            13)
                show_system_monitor
                ;;
            14|[Qq])
                clear
                echo -e "${GRAD1}╔══════════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${GRAD1}║${NC}                                                                  ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}    ${CYAN}Thank you for using ${WHITE}${BOLD}EMMKASHTECH VPS SCRIPT${NC}${CYAN}!${NC}             ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}                                                                  ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}    ${WHITE}🌟 Visit us: ${YELLOW}https://github.com/mmkash-web/vps${NC}        ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}    ${WHITE}📧 Support: ${YELLOW}support@emmkashtech.com${NC}                   ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}                                                                  ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}    ${GREEN}${BOLD}Professional VPS Solutions by EMMKASHTECH${NC}               ${GRAD1}║${NC}"
                echo -e "${GRAD1}║${NC}                                                                  ${GRAD1}║${NC}"
                echo -e "${GRAD1}╚══════════════════════════════════════════════════════════════════╝${NC}"
                echo
                exit 0
                ;;
            [Rr])
                continue
                ;;
            [Hh])
                show_help
                ;;
            [Aa])
                show_about
                ;;
            *)
                echo -e "${RED}❌ Invalid option! Please select 1-14 or use quick actions.${NC}"
                echo -e "${CYAN}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
        esac
    done
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi