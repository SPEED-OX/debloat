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

print_warning() {
    echo -e "\n${RED_COLOR}[WARNING]${RESET_COLOR} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update Termux packages automatically
update_termux() {
    print_status "Updating Termux package list..."
    
    # Set environment variables to avoid any interactive prompts
    export DEBIAN_FRONTEND=noninteractive
    export APT_LISTCHANGES_FRONTEND=none
    export NEEDRESTART_MODE=a
    
    # Update package list
    if ! yes | pkg update >/dev/null 2>&1; then
        print_warning "Package list update had issues, but continuing..."
    fi
    
    print_status "Upgrading installed packages (this may take a while)..."
    
    # Try multiple approaches for upgrade to ensure it's non-interactive
    if ! yes | pkg upgrade >/dev/null 2>&1; then
        print_warning "Some packages couldn't be upgraded, but continuing with installation..."
        print_status "Attempting alternative upgrade method..."
        
        # Alternative: try with apt directly
        if ! yes | apt upgrade >/dev/null 2>&1; then
            print_warning "Package upgrade completed with warnings, continuing..."
        fi
    fi
    
    print_success
}

# Function to install required packages
install_packages() {
    local packages=("git" "python" "android-tools")
    
    print_status "Installing required packages..."
    
    for package in "${packages[@]}"; do
        if command_exists "$package" || command_exists "${package}3"; then
            print_status "$package is already installed"
        else
            print_status "Installing $package..."
            
            # Try multiple installation methods
            if ! yes | pkg install "$package" >/dev/null 2>&1; then
                if ! yes | apt install "$package" >/dev/null 2>&1; then
                    print_error "Failed to install $package"
                    echo -e "Trying to continue without $package..."
                    continue
                fi
            fi
            
            # Verify installation
            if command_exists "$package" || command_exists "${package}3"; then
                print_status "$package installed successfully"
            else
                print_warning "$package installation unclear, but continuing..."
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
            print_warning "Failed to update repository, but existing version will be used"
        else
            print_status "Repository updated successfully"
        fi
    else
        print_status "Cloning repository from GitHub..."
        
        if ! git clone "$REPO_URL" "$DEST_DIR" >/dev/null 2>&1; then
            print_error "Failed to clone repository"
            echo -e "Please check your internet connection and try again."
            echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
            exit 1
        fi
        
        cd "$DEST_DIR" || exit 1
        print_status "Repository cloned successfully"
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
        echo -e "Repository structure may have changed."
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
                print_status "Alias added to $(basename "$config_file")"
            else
                print_status "Alias already exists in $(basename "$config_file")"
            fi
        fi
    done
    
    print_success
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    local checks_passed=0
    local total_checks=3
    local issues=()
    
    # Check if python3 is available
    if command_exists python3; then
        ((checks_passed++))
        print_status "✓ Python3 is available"
    else
        issues+=("Python3 not found")
    fi
    
    # Check if git is available
    if command_exists git; then
        ((checks_passed++))
        print_status "✓ Git is available"
    else
        issues+=("Git not found")
    fi
    
    # Check if debloater.py exists and is executable
    if [ -x "$DEST_DIR/debloater.py" ]; then
        ((checks_passed++))
        print_status "✓ debloater.py is ready"
    else
        issues+=("debloater.py not found or not executable")
    fi
    
    # ADB check is optional since android-tools might not install properly
    if command_exists adb; then
        print_status "✓ ADB is available"
    else
        print_warning "ADB not found - you may need to install android-tools manually"
        echo -e "Run: ${GREEN_COLOR}pkg install android-tools${RESET_COLOR}"
    fi
    
    if [ $checks_passed -eq $total_checks ]; then
        print_success
        return 0
    else
        print_error "Installation verification failed ($checks_passed/$total_checks critical checks passed)"
        for issue in "${issues[@]}"; do
            echo -e "  - $issue"
        done
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        return 1
    fi
}

# Function to display final instructions
show_completion_message() {
    local separator_line
    separator_line=$(printf "%0.s─" {1..60})
    
    echo -e "\n${GREEN_COLOR}${separator_line}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${separator_line}${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Usage Options:${RESET_COLOR}"
    echo -e "${GREEN_COLOR}1.${RESET_COLOR} Type ${GREEN_COLOR}'debloat'${RESET_COLOR} from anywhere in Termux"
    echo -e "${GREEN_COLOR}2.${RESET_COLOR} Or run ${GREEN_COLOR}'python3 $DEST_DIR/debloater.py'${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Important Notes:${RESET_COLOR}"
    echo -e "• Enable USB debugging on your Android device"
    echo -e "• Connect device via USB before running debloater"
    echo -e "• If ADB is not working, run: ${GREEN_COLOR}pkg install android-tools${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Support:${RESET_COLOR} ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${separator_line}${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Restarting shell to activate 'debloat' command...${RESET_COLOR}"
}

# Main installation function
main() {
    # Clear screen for better presentation
    clear
    
    # Print header
    print_header
    
    # Check if we're running in Termux
    if [ ! -d "/data/data/com.termux" ] && [ ! -d "$PREFIX" ]; then
        print_warning "This script is optimized for Termux, but attempting to continue..."
    fi
    
    # Step 1: Update and upgrade Termux (with better error handling)
    update_termux
    
    # Step 2: Install required packages (with fallback methods)
    install_packages
    
    # Step 3: Setup repository
    setup_repository
    
    # Step 4: Set up permissions
    setup_permissions
    
    # Step 5: Create alias
    create_alias
    
    # Step 6: Verify installation (with detailed reporting)
    if verify_installation; then
        # Step 7: Show completion message
        show_completion_message
        
        # Make alias available in current session
        exec bash -l
    else
        echo -e "\n${RED_COLOR}Installation completed with issues.${RESET_COLOR}"
        echo -e "You can still try running: ${GREEN_COLOR}python3 $DEST_DIR/debloater.py${RESET_COLOR}"
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        exit 1
    fi
}

# Run main function
main "$@"
