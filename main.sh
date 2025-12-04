#!/bin/bash


# Get the directory where THIS script is stored
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# LOAD SETTINGS (With Error Check)
CONFIG_FILE="$SCRIPT_DIR/config/settings.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "CRITICAL ERROR: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure the logs folder exists
LOG_DIR=$(dirname "$LOG_FILE")
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    # If mkdir fails, we can't log to file, so we print to screen
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Could not create log directory at $LOG_DIR${NC}"
    fi
fi

# Function to write to log
log_main_action() {
    local MESSAGE="$1"
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [SYSTEM] $MESSAGE" >> "$LOG_FILE"
}

# Log that the session started
log_main_action "Admin session started"

# Menu Function
show_menu() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}       FEDORA SYSADMIN AUTOMATOR v1.0            ${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo "1. System Monitoring (CPU/RAM/Disk)"
    echo "2. User Management"
    echo "3. Backup & Storage"
    echo "4. Network Tools"
    echo "5. View Logs"
    echo "0. Exit"
    echo -e "${BLUE}=================================================${NC}"
}

# Logic Loop
while true; do
    show_menu
    read -p "Select an option [0-5]: " CHOICE
    case $CHOICE in
        1) ./modules/monitor.sh ;;
        2) ./modules/users.sh ;;
        3) ./modules/storage.sh ;;
        4) ./modules/network.sh ;;
        5) ./modules/log.sh ;;
        0)
            log_main_action "Admin session ended"
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
            
        *) echo -e "${RED}Invalid Option${NC}"; sleep 1 ;;
    esac
done
