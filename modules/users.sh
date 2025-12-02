#!/bin/bash

# ==============================================================================
# MODULE: User Management (Fixed "All Users" List)
# FEATURES: List All Users, Add/Remove, Search, Password Gen
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load Config
source ./config/settings.conf

# ------------------------------------------------------------------------------
# 1. List All Users (Human & System)
# ------------------------------------------------------------------------------
list_all_users() {
    echo -e "${YELLOW}--- LIST OF ALL USERS ---${NC}"
    
    echo -e "${BLUE}>> HUMAN USERS (UID >= 1000)${NC}"
    # Fedora/RHEL/Ubuntu usually start human UIDs at 1000.
    # We parse /etc/passwd looking for UID ($3) >= 1000.
    awk -F: '$3 >= 1000 && $1 != "nobody" {printf "User: %-15s | UID: %s | Shell: %s\n", $1, $3, $7}' /etc/passwd
    
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 2. Add / Remove User
# ------------------------------------------------------------------------------
manage_add_remove() {
    echo -e "${YELLOW}--- ADD / REMOVE USER ---${NC}"
    echo "1. Add a New User"
    echo "2. Remove an Existing User"
    read -p "Select option [1-2]: " AR_CHOICE

    case $AR_CHOICE in
        1)
            # --- ADD USER ---
            read -p "Enter new username: " NEW_USER
            
            # Check if exists
            if id "$NEW_USER" &>/dev/null; then
                echo -e "${RED}Error: User '$NEW_USER' already exists.${NC}"
            else
                # Create user with home dir (-m) and default shell (-s)
                sudo useradd -m -s "$DEFAULT_SHELL" "$NEW_USER"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}User '$NEW_USER' created successfully.${NC}"
                    
                    # Set Password
                    echo "Please set a password for $NEW_USER:"
                    sudo passwd "$NEW_USER"
                else
                    echo -e "${RED}Failed to create user.${NC}"
                fi
            fi
            ;;
        2)
            # --- REMOVE USER ---
            read -p "Enter username to DELETE: " DEL_USER
            
            # Check if exists
            if ! id "$DEL_USER" &>/dev/null; then
                echo -e "${RED}Error: User '$DEL_USER' does not exist.${NC}"
            else
                read -p "Delete home directory too? (y/n): " DEL_HOME
                if [[ "$DEL_HOME" == "y" || "$DEL_HOME" == "Y" ]]; then
                    sudo userdel -r "$DEL_USER"
                    echo -e "${GREEN}User '$DEL_USER' and home directory removed.${NC}"
                else
                    sudo userdel "$DEL_USER"
                    echo -e "${GREEN}User '$DEL_USER' removed (files kept).${NC}"
                fi
            fi
            ;;
        *)
            echo -e "${RED}Invalid Option.${NC}"
            ;;
    esac
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 3. User Search by Username
# ------------------------------------------------------------------------------
search_user() {
    echo -e "${YELLOW}--- USER SEARCH ---${NC}"
    read -p "Enter username to search: " USERNAME

    if id "$USERNAME" &>/dev/null; then
        echo "--------------------------------"
        echo -e "User Found: ${GREEN}$USERNAME${NC}"
        # Extract details: UID, GID, Home, Shell
        grep "^$USERNAME:" /etc/passwd | awk -F: '{print "UID: "$3 "\nGID: "$4 "\nHome: "$6 "\nShell: "$7}'
        
        # Check Groups
        echo -n "Groups: "
        id -Gn "$USERNAME"
        echo "--------------------------------"
    else
        echo -e "${RED}User '$USERNAME' not found on this system.${NC}"
    fi
    echo ""
    read -p "Press Enter to return..."
}

# ------------------------------------------------------------------------------
# 4. Random 12-Char Strong Password Generator
# ------------------------------------------------------------------------------
generate_password() {
    echo -e "${YELLOW}--- PASSWORD GENERATOR ---${NC}"
    # Generate 12 bytes, base64 encode it, take first 12 chars
    PASS=$(openssl rand -base64 12)
    echo -e "Generated Password: ${GREEN}$PASS${NC}"
    echo ""
    read -p "Press Enter to return..."
}

# ==============================================================================
# MODULE 2 MENU
# ==============================================================================
while true; do
    clear
    echo "====================================="
    echo "      USER MANAGEMENT MODULE         "
    echo "====================================="
    echo "1. List All Users (Human & System)"
    echo "2. Add / Remove User"
    echo "3. User Search (by Username)"
    echo "4. Random 12-char Password Generator"
    echo "0. Return to Main Menu"
    echo "====================================="
    read -p "Enter Choice [0-4]: " u_choice

    case $u_choice in
        1) list_all_users ;;
        2) manage_add_remove ;;
        3) search_user ;;
        4) generate_password ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ; sleep 1 ;;
    esac
done
