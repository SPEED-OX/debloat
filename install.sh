#!/bin/bash

# install.sh - Universal Android Bloatware Remover Setup Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat
# Repository: https://github.com/SPEED-OX/debloate

# ANSI color codes matching debloater.py design
RESET_COLOR='\033[0m'
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Repository configuration
REPO_URL="https://github.com/SPEED-OX/debloate"
DEST_DIR="$HOME/debloater"
SUPPORT_GROUP_URL="https://t.me/TechGeekZ_chat"

# Function to create separator line
create_separator() {
    printf "%0.s─" {1..50}
}

# Function to print colored messages
print_header() {
    echo -e "\n${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
    echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
    echo -e "Author: TechGeekZ"
    echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}$(create_separator)${RESET_COLOR}"
}

print_status() {
    echo -e "\n${GREEN_COLOR}~ $1${RESET_COLOR}"
}

print_success() {
    echo -e "\n${GREEN_COLOR}SUCCESS ! ! ${RESET_COLOR}"
}

print_error() {
    echo -e "\n${RED_COLOR}[ERROR]${RESET_COLOR} $1"
}

# Function to update and install packages
setup_packages() {
    print_status "Updating package list..."
    apt update -y >/dev/null 2>&1
    
    print_status "Installing python3..."
    apt install -y python3 >/dev/null 2>&1
    
    print_status "Installing android-tools..."
    apt install -y android-tools >/dev/null 2>&1
    
    print_success
}

# Function to clone repository
setup_repository() {
    print_status "Downloading debloater from GitHub..."
    
    if [ -d "$DEST_DIR" ]; then
        rm -rf "$DEST_DIR"
    fi
    
    if ! git clone "$REPO_URL" "$DEST_DIR" >/dev/null 2>&1; then
        # Fallback: use curl if git is not available
        mkdir -p "$DEST_DIR"
        if ! curl -sL "$REPO_URL/archive/main.zip" -o /tmp/debloater.zip; then
            print_error "Failed to download repository"
            exit 1
        fi
        unzip -q /tmp/debloater.zip -d /tmp/
        cp -r /tmp/debloate-main/* "$DEST_DIR/"
        rm -rf /tmp/debloater.zip /tmp/debloate-main
    fi
    
    chmod +x "$DEST_DIR/debloater.py"
    print_success
}

# Function to create alias
create_alias() {
    print_status "Creating 'debloat' alias..."
    
    local alias_command="alias debloat='python3 $DEST_DIR/debloater.py'"
    
    if ! grep -q "alias debloat=" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Universal Android Bloatware Remover alias" >> "$HOME/.bashrc"
        echo "$alias_command" >> "$HOME/.bashrc"
    fi
    
    print_success
}

# Function to display completion message
show_completion_message() {
    local separator_line
    separator_line=$(printf "%0.s─" {1..60})
    
    echo -e "\n${GREEN_COLOR}${separator_line}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${separator_line}${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Usage:${RESET_COLOR} Type ${GREEN_COLOR}'debloat'${RESET_COLOR} from anywhere in Termux"
    echo -e "\n${GREEN_COLOR}Support:${RESET_COLOR} ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${separator_line}${RESET_COLOR}"
}

# Main function
main() {
    clear
    print_header
    
    setup_packages
    setup_repository
    create_alias
    
    show_completion_message
    exec bash -l
}

main "$@"
