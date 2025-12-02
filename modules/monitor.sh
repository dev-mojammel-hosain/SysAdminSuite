#!/bin/bash

# ==============================================================================
# MODULE: System Monitoring
# TARGET: Fedora Linux
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ROBUST CONFIG LOAD
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/../config/settings.conf"

# Logging Function
log_action() {
    local MESSAGE="$1"
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [MONITOR] $MESSAGE" >> "$LOG_FILE"
}

# 1. OS Information
show_os_info() {
    echo -e "${YELLOW}--- SYSTEM INFORMATION ---${NC}"
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "OS: $PRETTY_NAME"
    fi
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo ""
}

# 2. RAM Usage (Fixed: Shows 'Available' instead of strict 'Free')
show_ram() {
    echo -e "${YELLOW}--- MEMORY USAGE ---${NC}"
    # We use column $7 (Available) instead of $4 (Free) to match Total - Used
    free -h | awk 'NR==2{printf "Total: %s | Used: %s | Available: %s\n", $2, $3, $7}'
    echo ""
}

# 3. Disk Usage
show_disk() {
    echo -e "${YELLOW}--- DISK USAGE (Root) ---${NC}"
    # Get usage percentage of root /
    USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    
    if [ "$USAGE" -gt 80 ]; then
        echo -e "${RED}CRITICAL: Disk Usage is at ${USAGE}%!${NC}"
        log_action "WARNING: Disk Usage is High ($USAGE%)"
    else
        echo -e "${GREEN}OK: Disk Usage is at ${USAGE}%${NC}"
    fi
    
    df -h / | awk 'NR==2{print "Size: "$2 " | Used: "$3 " | Avail: "$4}'
    echo ""
}

# 4. Uptime (Replaces System Load)
show_uptime() {
    echo -e "${YELLOW}--- SYSTEM UPTIME ---${NC}"
    # -p prints it in a pretty format
    uptime -p
    echo ""
}

# 5. Top 5 Processes (New Feature)
show_processes() {
    echo -e "${YELLOW}--- TOP 5 PROCESSES (By CPU) ---${NC}"
    echo "PID    COMMAND         %CPU  %MEM"
    echo "---------------------------------"
    
    ps -Ao pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
    
    echo ""
}

# EXECUTE FUNCTIONS
clear

# Log that the admin opened this module
log_action "Admin viewed System Health Dashboard"

echo "=========================================="
echo "      SYSTEM HEALTH DASHBOARD             "
echo "=========================================="
show_os_info
show_uptime
show_ram
show_disk
show_processes
echo "=========================================="
read -p "Press Enter to return to menu..."
