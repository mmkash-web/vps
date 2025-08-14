#!/bin/bash

# EMMKASHTECH VPS Script v2.0
# Compatible with Ubuntu 18.04, 20.04, 22.04, 24.04 LTS
# Advanced Multi-Protocol VPN Installation System

# Color codes for modern output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Root permission check
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}❌ Error: This script must be run as root${NC}"
    echo -e "${CYAN}Please run: ${WHITE}sudo $0${NC}"
    exit 1
fi

# Virtualization compatibility check
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo -e "${RED}❌ Error: OpenVZ virtualization is not supported${NC}"
    echo -e "${CYAN}This script requires KVM, VMware, or physical hardware${NC}"
    exit 1
fi

# Ubuntu version compatibility check with 24.04 support
check_ubuntu_compatibility() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        
        echo -e "${CYAN}🔍 Checking system compatibility...${NC}"
        echo -e "${WHITE}Detected OS: ${YELLOW}$PRETTY_NAME${NC}"
        
        if [[ "$ID" != "ubuntu" ]]; then
            echo -e "${RED}❌ Error: This script is designed for Ubuntu only${NC}"
            echo -e "${CYAN}Detected: $PRETTY_NAME${NC}"
            exit 1
        fi
        
        case $VERSION_ID in
            "18.04")
                echo -e "${GREEN}✅ Ubuntu 18.04 LTS - Supported${NC}"
                UBUNTU_CODENAME="bionic"
                ;;
            "20.04")
                echo -e "${GREEN}✅ Ubuntu 20.04 LTS - Supported${NC}"
                UBUNTU_CODENAME="focal"
                ;;
            "22.04")
                echo -e "${GREEN}✅ Ubuntu 22.04 LTS - Fully Supported${NC}"
                UBUNTU_CODENAME="jammy"
                ;;
            "24.04")
                echo -e "${GREEN}✅ Ubuntu 24.04 LTS - Fully Supported (Latest)${NC}"
                UBUNTU_CODENAME="noble"
                # Ubuntu 24.04 specific optimizations
                export DEBIAN_FRONTEND=noninteractive
                ;;
            *)
                echo -e "${YELLOW}⚠️  Warning: Ubuntu $VERSION_ID may not be fully tested${NC}"
                echo -e "${CYAN}Officially supported: 18.04, 20.04, 22.04, 24.04 LTS${NC}"
                echo -e "${WHITE}Continue installation? [y/N]:${NC}"
                read -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${CYAN}Installation cancelled by user${NC}"
                    exit 1
                fi
                UBUNTU_CODENAME="unknown"
                ;;
        esac
    else
        echo -e "${RED}❌ Error: Cannot detect OS version${NC}"
        exit 1
    fi
}

# System requirements check
check_system_requirements() {
    echo -e "${CYAN}🔧 Checking system requirements...${NC}"
    
    # Memory check
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $TOTAL_MEM -lt 512 ]]; then
        echo -e "${RED}❌ Error: Minimum 512MB RAM required${NC}"
        echo -e "${CYAN}Current: ${TOTAL_MEM}MB${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Memory: ${TOTAL_MEM}MB - OK${NC}"
    
    # Disk space check
    AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
    SPACE_GB=$((AVAILABLE_SPACE / 1024 / 1024))
    if [[ $SPACE_GB -lt 2 ]]; then
        echo -e "${RED}❌ Error: Minimum 2GB free space required${NC}"
        echo -e "${CYAN}Current: ${SPACE_GB}GB${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Disk Space: ${SPACE_GB}GB available - OK${NC}"
    
    # Network connectivity check
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}❌ Error: No internet connectivity${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Network Connectivity - OK${NC}"
}

# Modern package management for Ubuntu 24.04+
update_system_packages() {
    echo -e "${CYAN}📦 Updating system packages for ${UBUNTU_CODENAME}...${NC}"
    
    # Update package lists
    apt update -qq
    
    # Ubuntu 24.04 specific package handling
    if [[ "$VERSION_ID" == "24.04" ]]; then
        # Handle new package names in Ubuntu 24.04
        echo -e "${YELLOW}🔄 Configuring Ubuntu 24.04 LTS specific packages...${NC}"
        
        # Install modern versions of required packages
        apt install -y \
            software-properties-common \
            apt-transport-https \
            ca-certificates \
            gnupg \
            lsb-release \
            curl \
            wget \
            unzip \
            bzip2 \
            gzip \
            coreutils \
            screen \
            net-tools \
            python3 \
            python3-pip 2>/dev/null || {
                echo -e "${YELLOW}⚠️  Some packages may not be available in Ubuntu 24.04 yet${NC}"
            }
    else
        # Standard package installation for older Ubuntu versions
        apt install -y \
            software-properties-common \
            apt-transport-https \
            ca-certificates \
            gnupg \
            lsb-release \
            curl \
            wget \
            unzip \
            bzip2 \
            gzip \
            coreutils \
            screen \
            net-tools
    fi
    
    echo -e "${GREEN}✅ System packages updated successfully${NC}"
}

# Pre-installation checks
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}                                                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}    ${CYAN}🚀 ${WHITE}${BOLD}EMMKASHTECH VPS SCRIPT v2.0${NC}${CYAN} 🚀${NC}                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}    ${WHITE}Professional Multi-Protocol VPN Installation${NC}        ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}                                                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo

check_ubuntu_compatibility
check_system_requirements
update_system_packages

echo -e "${GREEN}🎯 All compatibility checks passed!${NC}"
echo -e "${CYAN}📋 Proceeding with EMMKASHTECH VPS installation...${NC}"
echo
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Link Hosting Kalian Untuk Ssh Vpn - EMMKASHTECH
akbarvpn="raw.githubusercontent.com/mmkash-web/vps/main/ssh"
# Link Hosting Kalian Untuk Sstp - EMMKASHTECH
akbarvpnn="raw.githubusercontent.com/mmkash-web/vps/main/sstp"
# Link Hosting Kalian Untuk Ssr - EMMKASHTECH
akbarvpnnn="raw.githubusercontent.com/mmkash-web/vps/main/ssr"
# Link Hosting Kalian Untuk Shadowsocks - EMMKASHTECH
akbarvpnnnn="raw.githubusercontent.com/mmkash-web/vps/main/shadowsocks"
# Link Hosting Kalian Untuk Wireguard - EMMKASHTECH
akbarvpnnnnn="raw.githubusercontent.com/mmkash-web/vps/main/wireguard"
# Link Hosting Kalian Untuk Xray - EMMKASHTECH
akbarvpnnnnnn="raw.githubusercontent.com/mmkash-web/vps/main/xray"
# Link Hosting Kalian Untuk Ipsec - EMMKASHTECH
akbarvpnnnnnnn="raw.githubusercontent.com/mmkash-web/vps/main/ipsec"
# Link Hosting Kalian Untuk Backup - EMMKASHTECH
akbarvpnnnnnnnn="raw.githubusercontent.com/mmkash-web/vps/main/backup"
# Link Hosting Kalian Untuk Websocket - EMMKASHTECH
akbarvpnnnnnnnnn="raw.githubusercontent.com/mmkash-web/vps/main/websocket"
# Link Hosting Kalian Untuk Ohp - EMMKASHTECH
akbarvpnnnnnnnnnn="raw.githubusercontent.com/mmkash-web/vps/main/ohp"

# Getting
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
IZIN=$(wget -qO- ipinfo.io/ip);

rm -f setup.sh
clear
if [ -f "/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 0
fi
mkdir /var/lib/emmkashtech;
echo "IP=" >> /var/lib/emmkashtech/ipvps.conf
wget https://${akbarvpn}/cf.sh && chmod +x cf.sh && ./cf.sh
#install v2ray
wget https://${akbarvpnnnnnn}/ins-xray.sh && chmod +x ins-xray.sh && screen -S xray ./ins-xray.sh
#install ssh ovpn
wget https://${akbarvpn}/ssh-vpn.sh && chmod +x ssh-vpn.sh && screen -S ssh-vpn ./ssh-vpn.sh
wget https://${akbarvpnn}/sstp.sh && chmod +x sstp.sh && screen -S sstp ./sstp.sh
#install ssr
wget https://${akbarvpnnn}/ssr.sh && chmod +x ssr.sh && screen -S ssr ./ssr.sh
wget https://${akbarvpnnnn}/sodosok.sh && chmod +x sodosok.sh && screen -S ss ./sodosok.sh
#installwg
wget https://${akbarvpnnnnn}/wg.sh && chmod +x wg.sh && screen -S wg ./wg.sh
#install L2TP
wget https://${akbarvpnnnnnnn}/ipsec.sh && chmod +x ipsec.sh && screen -S ipsec ./ipsec.sh
wget https://${akbarvpnnnnnnnn}/set-br.sh && chmod +x set-br.sh && ./set-br.sh
# Websocket
wget https://${akbarvpnnnnnnnnn}/edu.sh && chmod +x edu.sh && ./edu.sh
# Ohp Server
wget https://${akbarvpnnnnnnnnnn}/ohp.sh && chmod +x ohp.sh && ./ohp.sh

rm -f /root/ssh-vpn.sh
rm -f /root/sstp.sh
rm -f /root/wg.sh
rm -f /root/ss.sh
rm -f /root/ssr.sh
rm -f /root/ins-xray.sh
rm -f /root/ipsec.sh
rm -f /root/set-br.sh
rm -f /root/edu.sh
rm -f /root/ohp.sh
cat <<EOF> /etc/systemd/system/autosett.service
[Unit]
Description=autosetting
Documentation=https://t.me/Akbar218

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/set.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable autosett
wget -O /etc/set.sh "https://${akbarvpn}/set.sh"
chmod +x /etc/set.sh
history -c
echo "1.2" > /home/ver
echo " "
echo "Installation has been completed!!"
echo " "
echo "============================================================================" | tee -a log-install.txt
echo "                          EMMKASHTECH VPS SCRIPT" | tee -a log-install.txt
echo "                      Powered by EMMKASHTECH Solutions" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "----------------------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 443, 22"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 990"  | tee -a log-install.txt
echo "   - Stunnel5                : 443, 445, 777"  | tee -a log-install.txt
echo "   - Dropbear                : 443, 109, 143"  | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8080"  | tee -a log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 89"  | tee -a log-install.txt
echo "   - Wireguard               : 7070"  | tee -a log-install.txt
echo "   - L2TP/IPSEC VPN          : 1701"  | tee -a log-install.txt
echo "   - PPTP VPN                : 1732"  | tee -a log-install.txt
echo "   - SSTP VPN                : 444"  | tee -a log-install.txt
echo "   - Shadowsocks-R           : 1443-1543"  | tee -a log-install.txt
echo "   - SS-OBFS TLS             : 2443-2543"  | tee -a log-install.txt
echo "   - SS-OBFS HTTP            : 3443-3543"  | tee -a log-install.txt
echo "   - XRAYS Vmess TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vmess None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Vless TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vless None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Trojan            : 2083"  | tee -a log-install.txt
echo "   - Websocket TLS           : 443"  | tee -a log-install.txt
echo "   - Websocket None TLS      : 8880"  | tee -a log-install.txt
echo "   - Websocket Ovpn          : 2086"  | tee -a log-install.txt
echo "   - OHP SSH                 : 8181"  | tee -a log-install.txt
echo "   - OHP Dropbear            : 8282"  | tee -a log-install.txt
echo "   - OHP OpenVPN             : 8383"  | tee -a log-install.txt
echo "   - Tr Go                   : 2087"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On 05.00 GMT +7" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo "   - White Label" | tee -a log-install.txt
echo "   - Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo " Reboot 15 Sec"
sleep 15
rm -f setup.sh
reboot
