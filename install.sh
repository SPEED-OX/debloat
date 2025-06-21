#!/bin/bash

# install.sh - Universal Android Bloatware Remover Setup Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat
# Repository: https://github.com/SPEED-OX/debloate

# ANSI color codes matching debloater.py design
RESET_COLOR='\033[0m'
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
LIGHT_BLUE_COLOR='\033[38;5;117m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Repository configuration
REPO_URL="https://github.com/SPEED-OX/debloate"
DEST_DIR="$HOME/debloater"
SUPPORT_GROUP_URL="https://t.me/TechGeekZ_chat"

# Function to print colored messages
print_header() {
    echo -e "\n${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
    echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
    echo -e "Author: TechGeekZ"
    echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${'─' * 50}${RESET_COLOR}"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update Termux packages automatically
update_termux() {
    print_status "Updating Termux package list..."
    
    # Set DEBIAN_FRONTEND to noninteractive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive
    
    # Update package list with automatic yes
    if ! pkg update -y >/dev/null 2>&1; then
        print_error "Failed to update package list"
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        exit 1
    fi
    
    print_status "Upgrading installed packages..."
    
    # Upgrade packages with automatic yes and no prompts
    if ! pkg upgrade -y >/dev/null 2>&1; then
        print_error "Failed to upgrade packages"
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        exit 1
    fi
    
    print_success
}

# Function to install required packages
install_packages() {
    local packages=("git" "python" "android-tools")
    
    for package in "${packages[@]}"; do
        if command_exists "$package" || command_exists "${package}3"; then
            print_status "$package is already installed"
        else
            print_status "Installing $package..."
            if ! pkg install -y "$package" >/dev/null 2>&1; then
                print_error "Failed to install $package"
                echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
                exit 1
            fi
        fi
    done
    
    print_success
}

# Function to clone or update repository
setup_repository() {
    if [ -d "$DEST_DIR" ]; then
        print_status "Repository exists. Updating to latest version..."
        cd "$DEST_DIR" || exit 1
        
        if ! git pull >/dev/null 2>&1; then
            print_error "Failed to update repository"
            echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
            exit 1
        fi
    else
        print_status "Cloning repository from GitHub..."
        
        if ! git clone "$REPO_URL" "$DEST_DIR" >/dev/null 2>&1; then
            print_error "Failed to clone repository"
            echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
            exit 1
        fi
        
        cd "$DEST_DIR" || exit 1
    fi
    
    print_success
}

# Function to set up executable permissions
setup_permissions() {
    print_status "Setting up executable permissions..."
    
    if [ -f "$DEST_DIR/debloater.py" ]; then
        chmod +x "$DEST_DIR/debloater.py"
        print_success
    else
        print_error "debloater.py not found in repository"
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        exit 1
    fi
}

# Function to create alias
create_alias() {
    print_status "Creating 'debloat' alias for easy execution..."
    
    local alias_command="alias debloat='python3 $DEST_DIR/debloater.py'"
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")
    
    for config_file in "${shell_configs[@]}"; do
        if [ -f "$config_file" ] || [ "$config_file" = "$HOME/.bashrc" ]; then
            # Create .bashrc if it doesn't exist
            if [ ! -f "$config_file" ]; then
                touch "$config_file"
            fi
            
            # Check if alias already exists
            if ! grep -q "alias debloat=" "$config_file" 2>/dev/null; then
                echo "" >> "$config_file"
                echo "# Universal Android Bloatware Remover alias" >> "$config_file"
                echo "$alias_command" >> "$config_file"
            fi
        fi
    done
    
    # Source the current shell configuration to make alias available immediately
    if [ -f "$HOME/.bashrc" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.bashrc" 2>/dev/null || true
    fi
    
    print_success
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    local checks_passed=0
    local total_checks=4
    
    # Check if python3 is available
    if command_exists python3; then
        ((checks_passed++))
    else
        print_error "Python3 not found"
    fi
    
    # Check if adb is available
    if command_exists adb; then
        ((checks_passed++))
    else
        print_error "ADB not found"
    fi
    
    # Check if git is available
    if command_exists git; then
        ((checks_passed++))
    else
        print_error "Git not found"
    fi
    
    # Check if debloater.py exists and is executable
    if [ -x "$DEST_DIR/debloater.py" ]; then
        ((checks_passed++))
    else
        print_error "debloater.py not found or not executable"
    fi
    
    if [ $checks_passed -eq $total_checks ]; then
        print_success
        return 0
    else
        print_error "Installation verification failed ($checks_passed/$total_checks checks passed)"
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        return 1
    fi
}

# Function to display final instructions
show_completion_message() {
    echo -e "\n${GREEN_COLOR}${'─' * 60}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${'─' * 60}${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Usage Options:${RESET_COLOR}"
    echo -e "${GREEN_COLOR}1.${RESET_COLOR} Type ${GREEN_COLOR}'debloat'${RESET_COLOR} from anywhere in Termux"
    echo -e "${GREEN_COLOR}2.${RESET_COLOR} Or run ${GREEN_COLOR}'python3 $DEST_DIR/debloater.py'${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Note:${RESET_COLOR} Make sure to enable USB debugging on your Android device"
    echo -e "and connect it via USB before running the debloater."
    echo -e "\n${GREEN_COLOR}Support:${RESET_COLOR} ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${'─' * 60}${RESET_COLOR}"
}

# Main installation function
main() {
    # Clear screen for better presentation
    clear
    
    # Print header
    print_header
    
    # Check if we're running in Termux
    if [ ! -d "/data/data/com.termux" ]; then
        print_error "This script is designed to run in Termux environment"
        exit 1
    fi
    
    # Step 1: Update and upgrade Termux
    update_termux
    
    # Step 2: Install required packages
    install_packages
    
    # Step 3: Setup repository
    setup_repository
    
    # Step 4: Set up permissions
    setup_permissions
    
    # Step 5: Create alias
    create_alias
    
    # Step 6: Verify installation
    if verify_installation; then
        # Step 7: Show completion message
        show_completion_message
        
        # Make alias available in current session
        exec bash
    else
        exit 1
    fi
}

# Run main function
main "$@"
