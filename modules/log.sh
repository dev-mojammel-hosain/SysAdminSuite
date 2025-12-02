#!/bin/bash

# ==============================================================================
# MODULE: Log Management & Audit
# FEATURES: View Project Logs, System Security Logs, Error Filter, Clear Logs
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load Config
source ./config/settings.conf

# Log file path (defined in settings.conf)
PROJECT_LOG=${LOG_FILE:-"./logs/sys_audit.log"}

# ------------------------------------------------------------------------------
# 1. View Recent Project Activity
# ------------------------------------------------------------------------------
view_project_logs() {
    echo -e "${YELLOW}--- RECENT PROJECT ACTIVITY ---${NC}"
    
    if [ ! -f "$PROJECT_LOG" ]; then
        echo -e "${RED}Log file not found at $PROJECT_LOG${NC}"
        # Create it if missing
        touch "$PROJECT_LOG"
        echo "[$(date)] [SYSTEM] [INFO] Log file created." >> "$PROJECT_LOG"
    fi

    # Show last 20 lines
    echo "Showing last 20 entries:"
    echo "------------------------------------------------"
    tail -n 20 "$PROJECT_LOG"
    echo "------------------------------------------------"
    
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 2. View System Security Events (Fedora /var/log/secure)
# ------------------------------------------------------------------------------
view_system_security() {
    echo -e "${YELLOW}--- SYSTEM SECURITY AUDIT (Fedora) ---${NC}"
    
    # Fedora uses /var/log/secure for auth logs. 
    # Ubuntu uses /var/log/auth.log. We check which one exists.
    if [ -f "/var/log/secure" ]; then
        SECURE_LOG="/var/log/secure"
    elif [ -f "/var/log/auth.log" ]; then
        SECURE_LOG="/var/log/auth.log"
    else
        echo -e "${RED}Could not find system security log.${NC}"
        read -p "Press Enter..."
        return
    fi

    echo "Reading $SECURE_LOG (Requires Sudo)..."
    echo "Looking for: Failed passwords, Sudo usage, New users"
    echo "------------------------------------------------"
    # Show last 15 lines of security events
    sudo tail -n 15 "$SECURE_LOG"
    echo "------------------------------------------------"
    
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 3. Filter Errors (Search Logic)
# ------------------------------------------------------------------------------
filter_error_logs() {
    echo -e "${YELLOW}--- ERROR LOG ANALYSIS ---${NC}"
    
    read -p "Search Project logs or System logs? (p/s): " CHOICE
    
    if [[ "$CHOICE" == "p" ]]; then
        TARGET="$PROJECT_LOG"
        NAME="Project Log"
    else
        TARGET="/var/log/secure" # Or /var/log/messages
        NAME="System Log"
    fi

    echo "Searching $NAME for 'Error', 'Fail', 'Denied'..."
    echo "------------------------------------------------"
    # grep -i (case insensitive) for keywords
    # sudo is needed if reading system logs
    sudo grep -iE "error|fail|denied|critical" "$TARGET" | tail -n 20
    echo "------------------------------------------------"
    
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 4. Clear/Reset Project Log
# ------------------------------------------------------------------------------
clear_logs() {
    echo -e "${YELLOW}--- CLEAR PROJECT LOGS ---${NC}"
    echo -e "${RED}Warning: This will delete all history in $PROJECT_LOG${NC}"
    read -p "Are you sure? (y/n): " CONFIRM
    
    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        # Overwrite file with empty string
        > "$PROJECT_LOG"
        # Add a fresh start entry
        echo "[$(date)] [$(whoami)] [INFO] Logs cleared by user." >> "$PROJECT_LOG"
        echo -e "${GREEN}Logs cleared successfully.${NC}"
    else
        echo "Operation cancelled."
    fi
    echo ""
    read -p "Press Enter to return..."
}

# ==============================================================================
# MODULE 5 MENU
# ==============================================================================
while true; do
    clear
    echo "====================================="
    echo "    LOG MANAGEMENT & AUDIT           "
    echo "====================================="
    echo "1. View Recent Project Activity"
    echo "2. View System Security (Auth/Sudo)"
    echo "3. Search for Errors (Filter)"
    echo "4. Clear/Reset Project Log"
    echo "0. Return to Main Menu"
    echo "====================================="
    read -p "Enter Choice [0-4]: " l_choice

    case $l_choice in
        1) view_project_logs ;;
        2) view_system_security ;;
        3) filter_error_logs ;;
        4) clear_logs ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ; sleep 1 ;;
    esac
done
