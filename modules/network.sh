#!/bin/bash

# ==============================================================================
# MODULE: Network Tools (Updated)
# FEATURES: Status Signal, IP Display, Port Scanner
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ------------------------------------------------------------------------------
# 1. Connectivity Tester (Status Signal + Optional Ping)
# ------------------------------------------------------------------------------
check_connectivity() {
    echo -e "${YELLOW}--- INTERNET CONNECTIVITY STATUS ---${NC}"
    
    # 1. Quick Check (Green/Red Signal)
    # Ping Google DNS once with a 2-second timeout
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo -e "Current Status: [ ${GREEN}ONLINE${NC} ]"
    else
        echo -e "Current Status: [ ${RED}OFFLINE${NC} ]"
    fi
    
    echo ""
    
    # 2. Ask for detailed test
    read -p "Do you want to run a ping test on major servers? (y/n): " RUN_TEST
    
    if [[ "$RUN_TEST" == "y" || "$RUN_TEST" == "Y" ]]; then
        echo "------------------------------------------------"
        echo "Testing Google DNS (8.8.8.8)..."
        ping -c 3 8.8.8.8
        
        echo "------------------------------------------------"
        echo "Testing Cloudflare DNS (1.1.1.1)..."
        ping -c 3 1.1.1.1
        
        echo "------------------------------------------------"
    else
        echo "Skipping detailed test."
    fi
    
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 2. Display Server IP Addresses
# ------------------------------------------------------------------------------
get_ip_addresses() {
    echo -e "${YELLOW}--- SERVER IP ADDRESSES ---${NC}"

    # Get Internal IP (LAN)
    # hostname -I gets all IPs, awk prints the first one
    PRIVATE_IP=$(hostname -I | awk '{print $1}')
    
    # Get Public IP (WAN)
    # Using curl with a timeout in case internet is down
    PUBLIC_IP=$(curl -s --max-time 3 ifconfig.me)

    if [ -z "$PRIVATE_IP" ]; then PRIVATE_IP="Unknown"; fi
    if [ -z "$PUBLIC_IP" ]; then PUBLIC_IP="${RED}Unreachable${NC}"; fi

    echo -e "Internal IP (LAN):  ${GREEN}$PRIVATE_IP${NC}"
    echo -e "Public IP (WAN):    ${BLUE}$PUBLIC_IP${NC}"
    
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 3. Port Scanner (Listening Services)
# ------------------------------------------------------------------------------
scan_ports() {
    echo -e "${YELLOW}--- LOCAL PORT SCANNER ---${NC}"
    echo "Scanning for open TCP/UDP ports..."
    echo "-------------------------------------------------------"
    printf "%-10s %-15s %-20s\n" "PROTO" "PORT" "PROCESS"
    echo "-------------------------------------------------------"
    
    # Use 'ss' command (modern replacement for netstat)
    # -t (tcp), -u (udp), -l (listening), -n (numeric), -p (process info)
    # sudo is required to see the Process Name
    sudo ss -tulnp | awk 'NR>1 {print $1, $5, $7}' | \
    sed 's/users:(("//g' | sed 's/",pid=.*//g' | \
    awk '{printf "%-10s %-15s %-20s\n", $1, $2, $3}'
    
    echo "-------------------------------------------------------"
    echo -e "${BLUE}Tip: These are the services actively accepting connections.${NC}"
    echo ""
    read -p "Press Enter to return..."
}

# ==============================================================================
# MODULE 4 MENU
# ==============================================================================
while true; do
    clear
    echo "====================================="
    echo "      NETWORK TOOLS MODULE           "
    echo "====================================="
    echo "1. Connectivity Tester (Status & Ping)"
    echo "2. Display Server IP Addresses"
    echo "3. Port Scanner (Open Ports)"
    echo "0. Return to Main Menu"
    echo "====================================="
    read -p "Enter Choice [0-3]: " n_choice

    case $n_choice in
        1) check_connectivity ;;
        2) get_ip_addresses ;;
        3) scan_ports ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ; sleep 1 ;;
    esac
done
