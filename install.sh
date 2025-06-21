#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Installation Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat

# ANSI color codes matching debloater.py design
RESET_COLOR='\033[0m'
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
LIGHT_BLUE_COLOR='\033[38;5;117m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Repository configuration
GITHUB_REPO="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME"
SUPPORT_GROUP_URL="https://t.me/TechGeekZ_chat"

# Progress tracking variables
charit=0
total=15
start_time=$(date +%s)

# Progress display function with enhanced formatting
_progress() {
    charit=$((charit + 1))
    percentage=$((charit * 100 / total))
    if [ $percentage -eq 100 ]; then
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        echo -ne "\r${GREEN_COLOR}Progress: $charit/$total ($percentage%) ${RESET_COLOR}${GREEN_COLOR}Installation Complete!${RESET_COLOR} Took: $elapsed_time seconds"
        echo ""
    else
        echo -ne "\r${GREEN_COLOR}Progress: $charit/$total ($percentage%)${RESET_COLOR}"
    fi
}

# Enhanced error handling function
handle_error() {
    local error_message="$1"
    local exit_code="$2"
    echo -e "\n${RED_COLOR}[ERROR]${RESET_COLOR} $error_message"
    echo -e "${TELEGRAM_COLOR}For support, visit: $SUPPORT_GROUP_URL${RESET_COLOR}"
    exit ${exit_code:-1}
}

# Network connectivity validation
check_network_connectivity() {
    echo -ne "\r${LIGHT_BLUE_COLOR}Checking network connectivity...${RESET_COLOR}"
    
    # Test GitHub connectivity
    curl -s --retry 3 --connect-timeout 10 $GITHUB_REPO > /dev/null
    exit_code=$?
    
    if [ $exit_code -eq 6 ]; then
        handle_error "Network connection failed. Please check your internet connection." 6
    elif [ $exit_code -eq 35 ]; then
        handle_error "GitHub is blocked in your current location. Consider using a VPN." 35
    elif [ $exit_code -ne 0 ]; then
        handle_error "Unable to reach GitHub repository. Exit code: $exit_code" $exit_code
    fi
}

# Termux API validation
validate_termux_environment() {
    if [ ! -d "/data/data/com.termux.api" ]; then
        echo -e "\n${RED_COLOR}[WARNING]${RESET_COLOR} com.termux.api app is not installed"
        echo -e "${LIGHT_BLUE_COLOR}This is optional but recommended for enhanced functionality${RESET_COLOR}"
        echo -e "${LIGHT_BLUE_COLOR}You can install it from F-Droid or Google Play Store${RESET_COLOR}"
    fi
}

# System update and package management
update_system_packages() {
    echo -ne "\r${LIGHT_BLUE_COLOR}Updating package repositories...${RESET_COLOR}"
    apt update > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
    _progress
    
    echo -ne "\r${LIGHT_BLUE_COLOR}Upgrading system packages...${RESET_COLOR}"
    apt upgrade -y > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
    _progress
}

# Essential package installation
install_essential_packages() {
    local packages=("python3" "android-tools")
    
    for package in "${packages[@]}"; do
        echo -ne "\r${LIGHT_BLUE_COLOR}Installing $package...${RESET_COLOR}"
        
        # Check if package is already installed and up to date
        installed=$(apt policy "$package" 2>/dev/null | grep 'Installed' | awk '{print $2}')
        candidate=$(apt policy "$package" 2>/dev/null | grep 'Candidate' | awk '{print $2}')
        
        if [ "$installed" != "$candidate" ] || [ "$installed" = "(none)" ]; then
            pkg install "$package" -y > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                handle_error "Failed to install $package" 1
            fi
        fi
        _progress
    done
}

# Python dependencies management
install_python_dependencies() {
    local python_libs=("requests" "colorama")
    
    for lib in "${python_libs[@]}"; do
        echo -ne "\r${LIGHT_BLUE_COLOR}Installing Python library: $lib...${RESET_COLOR}"
        
        # Check if library is installed and get versions
        installed_version=$(pip show "$lib" 2>/dev/null | grep Version | awk '{print $2}')
        
        if [ -z "$installed_version" ]; then
            pip install "$lib" -q
            if [ $? -ne 0 ]; then
                handle_error "Failed to install Python library: $lib" 1
            fi
        else
            # Attempt to upgrade if newer version available
            pip install --upgrade "$lib" -q > /dev/null 2>&1
        fi
        _progress
    done
}

# Download and install main debloater script
install_debloater_script() {
    echo -ne "\r${LIGHT_BLUE_COLOR}Downloading debloater script...${RESET_COLOR}"
    
    curl -s "$GITHUB_REPO/master/debloater.py" -o "$PREFIX/bin/debloater" 2>/dev/null
    if [ $? -ne 0 ]; then
        handle_error "Failed to download debloater.py from repository" 1
    fi
    
    chmod +x "$PREFIX/bin/debloater"
    _progress
}

# Download bloatware lists directory
install_bloatware_lists() {
    echo -ne "\r${LIGHT_BLUE_COLOR}Creating lists directory...${RESET_COLOR}"
    
    # Create lists directory in the same location as the script
    lists_dir="$PREFIX/bin/lists"
    mkdir -p "$lists_dir"
    _progress
    
    # Download individual brand lists
    local brands=("xiaomi" "samsung" "oneplus" "realme" "vivo" "oppo" "huawei" "common")
    
    for brand in "${brands[@]}"; do
        echo -ne "\r${LIGHT_BLUE_COLOR}Downloading $brand bloatware list...${RESET_COLOR}"
        
        curl -s "$GITHUB_REPO/master/lists/${brand}.txt" -o "$lists_dir/${brand}.txt" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "\n${RED_COLOR}[WARNING]${RESET_COLOR} Failed to download $brand.txt list"
        fi
        _progress
    done
}

# Create command aliases and shortcuts
setup_command_aliases() {
    echo -ne "\r${LIGHT_BLUE_COLOR}Setting up command aliases...${RESET_COLOR}"
    
    # Create alias in .bashrc for persistent access
    bashrc_file="$HOME/.bashrc"
    alias_line="alias debloater='python3 \$PREFIX/bin/debloater'"
    
    # Check if alias already exists
    if ! grep -q "alias debloater=" "$bashrc_file" 2>/dev/null; then
        echo "" >> "$bashrc_file"
        echo "# Universal Android Bloatware Remover alias" >> "$bashrc_file"
        echo "$alias_line" >> "$bashrc_file"
    fi
    
    # Source the bashrc to make alias available immediately
    source "$bashrc_file" 2>/dev/null || true
    _progress
    
    # Create direct executable link as backup
    echo -ne "\r${LIGHT_BLUE_COLOR}Creating executable shortcuts...${RESET_COLOR}"
    ln -sf "$PREFIX/bin/debloater" "$PREFIX/bin/bloatware-remover" 2>/dev/null
    _progress
}

# Validate installation integrity
validate_installation() {
    echo -ne "\r${LIGHT_BLUE_COLOR}Validating installation...${RESET_COLOR}"
    
    # Check if main script exists and is executable
    if [ ! -x "$PREFIX/bin/debloater" ]; then
        handle_error "Main debloater script is not properly installed or executable" 1
    fi
    
    # Check if at least common.txt exists
    if [ ! -f "$PREFIX/bin/lists/common.txt" ]; then
        echo -e "\n${RED_COLOR}[WARNING]${RESET_COLOR} Common bloatware list not found"
        echo -e "${LIGHT_BLUE_COLOR}Some functionality may be limited${RESET_COLOR}"
    fi
    
    # Verify Python3 installation
    if ! command -v python3 &> /dev/null; then
        handle_error "Python3 installation verification failed" 1
    fi
    
    # Verify ADB installation
    if ! command -v adb &> /dev/null; then
        handle_error "Android Debug Bridge (ADB) installation verification failed" 1
    fi
    
    _progress
}

# Display installation completion message
display_completion_message() {
    echo -e "\n"
    echo -e "${GREEN_COLOR}╔══════════════════════════════════════════════════════════════╗${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║                    INSTALLATION COMPLETE!                   ║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}╠══════════════════════════════════════════════════════════════╣${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR} Universal Android Bloatware Remover has been installed     ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR} successfully on your Termux environment.                   ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║                                                              ║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR} Usage Commands:                                             ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}   • ${LIGHT_BLUE_COLOR}debloater${RESET_COLOR}              - Run the debloater tool          ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}   • ${LIGHT_BLUE_COLOR}bloatware-remover${RESET_COLOR}      - Alternative command             ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}   • ${LIGHT_BLUE_COLOR}python3 \$PREFIX/bin/debloater${RESET_COLOR} - Direct execution      ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║                                                              ║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR} Support & Updates:                                          ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}   ${TELEGRAM_COLOR}Telegram: https://t.me/TechGeekZ_chat${RESET_COLOR}                ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}╚══════════════════════════════════════════════════════════════╝${RESET_COLOR}"
    echo -e "\n${GREEN_COLOR}Quick Start:${RESET_COLOR}"
    echo -e "1. Connect your Android device via USB"
    echo -e "2. Enable USB Debugging on your device"
    echo -e "3. Run: ${LIGHT_BLUE_COLOR}debloater${RESET_COLOR}"
    echo -e "\n${LIGHT_BLUE_COLOR}Restart your Termux session or run 'source ~/.bashrc' to ensure aliases work properly.${RESET_COLOR}\n"
}

# Main installation orchestration
main() {
    echo -e "\n${GREEN_COLOR}** Universal Android Bloatware Remover - Installer **${RESET_COLOR}"
    echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
    echo -e "Author: TechGeekZ"
    echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}$SUPPORT_GROUP_URL${RESET_COLOR}"
    echo -e "${GREEN_COLOR}${'─' * 50}${RESET_COLOR}"
    
    # Execute installation steps in sequence
    validate_termux_environment
    check_network_connectivity
    update_system_packages
    install_essential_packages
    install_python_dependencies
    install_debloater_script
    install_bloatware_lists
    setup_command_aliases
    validate_installation
    
    # Display completion message
    display_completion_message
}

# Error handling for script interruption
trap 'echo -e "\n${RED_COLOR}[ERROR]${RESET_COLOR} Installation interrupted. Please run the installer again."; exit 1' INT TERM

# Execute main installation function
main "$@"
