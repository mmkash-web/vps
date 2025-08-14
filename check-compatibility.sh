#!/bin/bash

# EMMKASHTECH VPS Compatibility Checker
# Comprehensive system analysis for Ubuntu 18.04 - 24.04 LTS

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                                                                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}    ${CYAN}🔍 ${WHITE}${BOLD}EMMKASHTECH COMPATIBILITY CHECKER${NC}${CYAN} 🔍${NC}            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}    ${WHITE}System Analysis for VPS Script Installation${NC}        ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}                                                                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# System information gathering
get_system_info() {
    echo -e "${CYAN}📊 Gathering system information...${NC}"
    echo
    
    # Basic system info
    HOSTNAME=$(hostname)
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    
    # OS Detection
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION"
        OS_ID="$ID"
        OS_VERSION_ID="$VERSION_ID"
        OS_CODENAME="$VERSION_CODENAME"
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
        OS_ID="unknown"
        OS_VERSION_ID="unknown"
        OS_CODENAME="unknown"
    fi
    
    # Hardware info
    CPU_CORES=$(nproc)
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
    TOTAL_DISK=$(df -h / | awk 'NR==2 {print $2}')
    AVAILABLE_DISK=$(df -h / | awk 'NR==2 {print $4}')
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    
    # Network
    PUBLIC_IP=$(curl -s --max-time 10 ipinfo.io/ip 2>/dev/null || echo "Unable to detect")
    LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "Unable to detect")
    
    # Virtualization
    VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "physical")
}

# Compatibility check functions
check_os_compatibility() {
    echo -e "${BLUE}┌─────────────────────── ${WHITE}${BOLD}OPERATING SYSTEM${NC}${BLUE} ───────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Hostname:${NC} ${WHITE}$HOSTNAME${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}OS:${NC} ${WHITE}$OS_NAME${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Version:${NC} ${WHITE}$OS_VERSION${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Codename:${NC} ${WHITE}$OS_CODENAME${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Architecture:${NC} ${WHITE}$ARCH${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Kernel:${NC} ${WHITE}$KERNEL${NC}"
    
    if [[ "$OS_ID" == "ubuntu" ]]; then
        case $OS_VERSION_ID in
            "24.04")
                echo -e "${BLUE}│${NC} ${GREEN}✅ Status: Ubuntu 24.04 LTS - FULLY SUPPORTED (Latest)${NC}"
                COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 25))
                ;;
            "22.04")
                echo -e "${BLUE}│${NC} ${GREEN}✅ Status: Ubuntu 22.04 LTS - FULLY SUPPORTED${NC}"
                COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 25))
                ;;
            "20.04")
                echo -e "${BLUE}│${NC} ${GREEN}✅ Status: Ubuntu 20.04 LTS - FULLY SUPPORTED${NC}"
                COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 25))
                ;;
            "18.04")
                echo -e "${BLUE}│${NC} ${YELLOW}⚠️  Status: Ubuntu 18.04 LTS - LEGACY SUPPORT${NC}"
                echo -e "${BLUE}│${NC} ${YELLOW}   (Consider upgrading to a newer LTS version)${NC}"
                COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 20))
                ;;
            *)
                echo -e "${BLUE}│${NC} ${RED}❌ Status: Ubuntu $OS_VERSION_ID - NOT TESTED${NC}"
                echo -e "${BLUE}│${NC} ${RED}   (May work but not guaranteed)${NC}"
                COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 10))
                ;;
        esac
    else
        echo -e "${BLUE}│${NC} ${RED}❌ Status: $OS_NAME - NOT SUPPORTED${NC}"
        echo -e "${BLUE}│${NC} ${RED}   (This script requires Ubuntu LTS)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 0))
    fi
    
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

check_hardware_requirements() {
    echo -e "${BLUE}┌─────────────────────── ${WHITE}${BOLD}HARDWARE REQUIREMENTS${NC}${BLUE} ─────────────────────┐${NC}"
    
    # Memory check
    echo -e "${BLUE}│${NC} ${CYAN}Total Memory:${NC} ${WHITE}${TOTAL_MEM}MB${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Available Memory:${NC} ${WHITE}${AVAILABLE_MEM}MB${NC}"
    if [[ $TOTAL_MEM -ge 1024 ]]; then
        echo -e "${BLUE}│${NC} ${GREEN}✅ Memory: Excellent (≥1GB)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 25))
    elif [[ $TOTAL_MEM -ge 512 ]]; then
        echo -e "${BLUE}│${NC} ${YELLOW}⚠️  Memory: Adequate (≥512MB)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 20))
    else
        echo -e "${BLUE}│${NC} ${RED}❌ Memory: Insufficient (<512MB)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 0))
    fi
    
    # CPU check
    echo -e "${BLUE}│${NC} ${CYAN}CPU Cores:${NC} ${WHITE}$CPU_CORES${NC}"
    if [[ $CPU_CORES -ge 2 ]]; then
        echo -e "${BLUE}│${NC} ${GREEN}✅ CPU: Multi-core (Excellent)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 15))
    else
        echo -e "${BLUE}│${NC} ${YELLOW}⚠️  CPU: Single-core (May be slow)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 10))
    fi
    
    # Disk space check
    echo -e "${BLUE}│${NC} ${CYAN}Total Disk:${NC} ${WHITE}$TOTAL_DISK${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Available Disk:${NC} ${WHITE}$AVAILABLE_DISK${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Disk Usage:${NC} ${WHITE}${DISK_USAGE}%${NC}"
    
    if [[ $DISK_USAGE -lt 70 ]]; then
        echo -e "${BLUE}│${NC} ${GREEN}✅ Disk Space: Plenty available${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 15))
    elif [[ $DISK_USAGE -lt 85 ]]; then
        echo -e "${BLUE}│${NC} ${YELLOW}⚠️  Disk Space: Moderate usage${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 10))
    else
        echo -e "${BLUE}│${NC} ${RED}❌ Disk Space: High usage (${DISK_USAGE}%)${NC}"
        COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 5))
    fi
    
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

check_virtualization() {
    echo -e "${BLUE}┌─────────────────────── ${WHITE}${BOLD}VIRTUALIZATION${NC}${BLUE} ───────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Type:${NC} ${WHITE}$VIRT_TYPE${NC}"
    
    case $VIRT_TYPE in
        "kvm"|"vmware"|"microsoft"|"xen"|"physical")
            echo -e "${BLUE}│${NC} ${GREEN}✅ Status: Fully Compatible${NC}"
            COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 20))
            ;;
        "openvz"|"lxc")
            echo -e "${BLUE}│${NC} ${RED}❌ Status: Not Supported${NC}"
            echo -e "${BLUE}│${NC} ${RED}   (Container virtualization limitations)${NC}"
            COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 0))
            ;;
        *)
            echo -e "${BLUE}│${NC} ${YELLOW}⚠️  Status: Unknown virtualization${NC}"
            COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + 10))
            ;;
    esac
    
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

check_network_connectivity() {
    echo -e "${BLUE}┌─────────────────────── ${WHITE}${BOLD}NETWORK CONNECTIVITY${NC}${BLUE} ─────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Public IP:${NC} ${WHITE}$PUBLIC_IP${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}Local IP:${NC} ${WHITE}$LOCAL_IP${NC}"
    
    # Test internet connectivity
    echo -e "${BLUE}│${NC} ${CYAN}Testing connectivity...${NC}"
    
    if ping -c 1 google.com &> /dev/null; then
        echo -e "${BLUE}│${NC} ${GREEN}✅ Internet: Connected${NC}"
        CONNECTIVITY_SCORE=10
    else
        echo -e "${BLUE}│${NC} ${RED}❌ Internet: No connectivity${NC}"
        CONNECTIVITY_SCORE=0
    fi
    
    # Test DNS resolution
    if nslookup google.com &> /dev/null; then
        echo -e "${BLUE}│${NC} ${GREEN}✅ DNS: Working${NC}"
        CONNECTIVITY_SCORE=$((CONNECTIVITY_SCORE + 5))
    else
        echo -e "${BLUE}│${NC} ${RED}❌ DNS: Resolution failed${NC}"
    fi
    
    # Test HTTPS access
    if curl -s --max-time 10 https://google.com &> /dev/null; then
        echo -e "${BLUE}│${NC} ${GREEN}✅ HTTPS: Accessible${NC}"
        CONNECTIVITY_SCORE=$((CONNECTIVITY_SCORE + 5))
    else
        echo -e "${BLUE}│${NC} ${RED}❌ HTTPS: Blocked or failed${NC}"
    fi
    
    COMPATIBILITY_SCORE=$((COMPATIBILITY_SCORE + CONNECTIVITY_SCORE))
    
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

show_recommendations() {
    echo -e "${PURPLE}┌─────────────────────── ${WHITE}${BOLD}RECOMMENDATIONS${NC}${PURPLE} ─────────────────────┐${NC}"
    
    if [[ $COMPATIBILITY_SCORE -ge 90 ]]; then
        echo -e "${PURPLE}│${NC} ${GREEN}🎉 EXCELLENT: Your system is perfect for EMMKASHTECH VPS!${NC}"
        echo -e "${PURPLE}│${NC} ${GREEN}   All requirements exceeded. Installation should be smooth.${NC}"
    elif [[ $COMPATIBILITY_SCORE -ge 75 ]]; then
        echo -e "${PURPLE}│${NC} ${GREEN}✅ GOOD: Your system meets all requirements${NC}"
        echo -e "${PURPLE}│${NC} ${GREEN}   Installation should work well with minor optimizations.${NC}"
    elif [[ $COMPATIBILITY_SCORE -ge 60 ]]; then
        echo -e "${PURPLE}│${NC} ${YELLOW}⚠️  ACCEPTABLE: System meets minimum requirements${NC}"
        echo -e "${PURPLE}│${NC} ${YELLOW}   Installation possible but consider upgrades.${NC}"
    else
        echo -e "${PURPLE}│${NC} ${RED}❌ NOT RECOMMENDED: System may not work properly${NC}"
        echo -e "${PURPLE}│${NC} ${RED}   Consider upgrading hardware or OS version.${NC}"
    fi
    
    echo -e "${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${CYAN}💡 Optimization Tips:${NC}"
    
    if [[ $TOTAL_MEM -lt 1024 ]]; then
        echo -e "${PURPLE}│${NC} ${YELLOW}• Consider adding more RAM for better performance${NC}"
    fi
    
    if [[ $DISK_USAGE -gt 80 ]]; then
        echo -e "${PURPLE}│${NC} ${YELLOW}• Free up disk space before installation${NC}"
    fi
    
    if [[ "$OS_VERSION_ID" == "18.04" ]]; then
        echo -e "${PURPLE}│${NC} ${YELLOW}• Ubuntu 18.04 is reaching end of life, consider upgrading${NC}"
    fi
    
    if [[ "$VIRT_TYPE" == "openvz" ]]; then
        echo -e "${PURPLE}│${NC} ${RED}• OpenVZ is not supported, use KVM or VMware instead${NC}"
    fi
    
    echo -e "${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${CYAN}🏆 Compatibility Score: ${WHITE}${COMPATIBILITY_SCORE}/100${NC}"
    
    echo -e "${PURPLE}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

# Main execution
main() {
    COMPATIBILITY_SCORE=0
    
    show_banner
    get_system_info
    check_os_compatibility
    check_hardware_requirements
    check_virtualization
    check_network_connectivity
    show_recommendations
    
    echo -e "${CYAN}🔗 Ready to install? Run the main EMMKASHTECH VPS script:${NC}"
    echo -e "${WHITE}wget https://raw.githubusercontent.com/mmkash-web/vps/main/setup.sh && chmod +x setup.sh && ./setup.sh${NC}"
    echo
}

# Run the compatibility checker
main