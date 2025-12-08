#!/bin/bash

# ==============================================================================
# MODULE: File & Storage Management (Updated)
# FEATURES: Dir Size, Large Files, Advanced Temp Cleaner, Home Backup
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load Config
source "$HOME/SysAdminSuite/config/settings.conf"

# Logging Function
log_action() {
    local MESSAGE="$1"
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [Storage] $MESSAGE" >> "$LOG_FILE"
}

# ------------------------------------------------------------------------------
# 1. Directory Size Calculator
# ------------------------------------------------------------------------------
calc_dir_size() {
    echo -e "${YELLOW}--- DIRECTORY SIZE CALCULATOR ---${NC}"
    read -p "Enter path to check (e.g., /home): " TARGET_DIR

    if [ -d "$TARGET_DIR" ]; then
        echo "Calculating size... (this may take a moment)"
        SIZE=$(sudo du -sh "$TARGET_DIR" 2>/dev/null | cut -f1)
        echo -e "Total Size of ${BLUE}$TARGET_DIR${NC}: ${GREEN}$SIZE${NC}"
        log_action "Searched Size of '$TARGET_DIR': '$SIZE'"
    else
        echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist.${NC}"
    fi
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 2. Large File Finder (Top 10)
# ------------------------------------------------------------------------------
find_large_files() {
    echo -e "${YELLOW}--- LARGE FILE FINDER (Top 10) ---${NC}"
    read -p "Enter directory to scan (Press Enter for /home): " SCAN_DIR
    
    if [ -z "$SCAN_DIR" ]; then
        SCAN_DIR="/home"
    fi

    if [ -d "$SCAN_DIR" ]; then
        echo "Scanning $SCAN_DIR..."
        echo "---------------------------------------------------"
        sudo find "$SCAN_DIR" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 10
        log_action "Large file viewed on $SCAN_DIR"
        echo "---------------------------------------------------"
    else
        echo -e "${RED}Error: Directory not found.${NC}"
    fi
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 3. Advanced Temp Cleaner (3 Options)
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 3. Temp Cleaner (Fixed & Cleaned)
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 3. Temp Cleaner (Now Removes Empty Folders)
# ------------------------------------------------------------------------------
clean_temp() {
    echo -e "${YELLOW}--- ADVANCED TEMP FILE CLEANER ---${NC}"
    TEMP_PATH="/tmp"
    
    echo "Select Cleanup Mode for $TEMP_PATH:"
    echo "1. Delete ALL files (Clean everything)"
    echo "2. Delete files older than 1 DAY"
    echo "3. Delete files older than 7 DAYS"
    echo "0. Cancel"
    read -p "Enter choice [0-3]: " T_CHOICE

    case $T_CHOICE in
        1)
            # Delete ALL Files
            echo "Deleting ALL files..."
            sudo find "$TEMP_PATH" -type f -delete 2>/dev/null
            
            # Delete Empty Directories (The Fix)
            # -mindepth 1 prevents it from trying to delete /tmp itself
            echo "Removing empty folders..."
            sudo find "$TEMP_PATH" -mindepth 1 -type d -empty -delete 2>/dev/null
            
            echo -e "${GREEN}Cleanup Complete (Files & Empty Folders removed).${NC}"
            log_action "Cleaned ALL files and empty folders from /tmp"
            ;;
        2)
            # Older than 1 Day
            echo "Deleting files older than 1 day..."
            sudo find "$TEMP_PATH" -type f -mtime +1 -delete 2>/dev/null
            
            # Remove empty folders older than 1 day
            sudo find "$TEMP_PATH" -mindepth 1 -type d -mtime +1 -empty -delete 2>/dev/null
            
            echo -e "${GREEN}Cleanup Complete (>1 Day removed).${NC}"
            log_action "Cleaned files older than 1 day from /tmp"
            ;;
        3)
            # Older than 7 Days
            echo "Deleting files older than 7 days..."
            sudo find "$TEMP_PATH" -type f -mtime +7 -delete 2>/dev/null
            
            # Remove empty folders older than 7 days
            sudo find "$TEMP_PATH" -mindepth 1 -type d -mtime +7 -empty -delete 2>/dev/null
            
            echo -e "${GREEN}Cleanup Complete (>7 Days removed).${NC}"
            log_action "Cleaned files older than 7 days from /tmp"
            ;;
        0)
            echo "Operation Cancelled."
            ;;
        *)
            echo -e "${RED}Invalid Option.${NC}"
            ;;
    esac
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 4. Simple Backup (To Home Directory)
# ------------------------------------------------------------------------------
run_backup() {
    echo -e "${YELLOW}--- BACKUP TO HOME FOLDER ---${NC}"
    
    # Logic to find the REAL user's home directory (even if running as sudo)
    # If SUDO_USER is set, use that. Otherwise use current USER.
    REAL_USER=${SUDO_USER:-$USER}
    # Get home dir from /etc/passwd to be safe
    REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
    
    # Set Backup Destination
    DEST_DIR="$REAL_HOME/sysadmin_backups"

    read -p "Enter full path to backup (e.g., /etc/ssh): " SRC_DIR

    if [ ! -d "$SRC_DIR" ]; then
        echo -e "${RED}Error: Source directory does not exist.${NC}"
        read -p "Press Enter..."
        return
    fi

    # Create destination if missing
    if [ ! -d "$DEST_DIR" ]; then
        echo "Creating backup folder at $DEST_DIR..."
        sudo mkdir -p "$DEST_DIR"
        # Fix permissions so the normal user owns their backup folder
        sudo chown "$REAL_USER":"$REAL_USER" "$DEST_DIR"
    fi

    # Create Filename
    FOLDER_NAME=$(basename "$SRC_DIR")
    TIMESTAMP=$(date +"%Y-%m-%d_%H%M")
    DEST_FILE="$DEST_DIR/backup_${FOLDER_NAME}_${TIMESTAMP}.tar.gz"

    echo "Backing up..."
    
    sudo tar -czf "$DEST_FILE" -C "$(dirname "$SRC_DIR")" "$FOLDER_NAME" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Backup Saved!${NC}"
        echo -e "Location: ${BLUE}$DEST_FILE${NC}"
        
        # Fix file ownership so the user can actually open it
        sudo chown "$REAL_USER":"$REAL_USER" "$DEST_FILE"
    else
        echo -e "${RED}[FAIL] Backup encountered errors.${NC}"
    fi
    echo ""
    read -p "Press Enter to return..."
}

# ==============================================================================
# MODULE 3 MENU
# ==============================================================================
while true; do
    clear
    echo "====================================="
    echo "    FILE & STORAGE MANAGEMENT        "
    echo "====================================="
    echo "1. Directory Size Calculator"
    echo "2. Find Large Files (Space Hogs)"
    echo "3. Clean Temp Files (Menu)"
    echo "4. Run Backup (To Home Folder)"
    echo "0. Return to Main Menu"
    echo "====================================="
    read -p "Enter Choice [0-4]: " s_choice

    case $s_choice in
        1) calc_dir_size ;;
        2) find_large_files ;;
        3) clean_temp ;;
        4) run_backup ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ; sleep 1 ;;
    esac
done
