#!/data/data/com.termux/files/usr/bin/bash

""" Universal Android Debloater - Installation Script
This script automatically installs the Universal Android Debloater in Termux
with all necessary dependencies and configurations.

For support, visit: https://t.me/TechGeekZ_chat
"""

# ANSI color codes matching debloater.py
RESET_COLOR='\033[0m'
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
LIGHT_BLUE_COLOR='\033[38;5;117m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Configuration variables
GITHUB_REPO="https://github.com/YourUsername/android-debloater"
INSTALL_DIR="$HOME/android-debloater"
SCRIPT_NAME="debloater.py"
LISTS_DIR="lists"
SUPPORT_GROUP_URL="https://t.me/TechGeekZ_chat"

check_termux_environment() {
    """ Checks if the script is running in Termux environment.
    Returns True if in Termux, False otherwise.
    """
    if [ ! -d "/data/data/com.termux" ]; then
        echo -e "**Checking Termux Environment: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        echo -e "${RED_COLOR}This installer requires Termux environment${RESET_COLOR}"
        echo "[Error] Please run this script in Termux."
        return 1
    fi
    
    echo -e "**Checking Termux Environment: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
    return 0
}

update_termux_packages() {
    """ Updates Termux package repositories without user confirmation.
    Returns 0 if successful, 1 if failed.
    """
    echo -e "\n**Updating Package Repositories..."
    
    if pkg update -y &>/dev/null; then
        echo -e "**Package Update Status: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
        return 0
    else
        echo -e "**Package Update Status: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        echo -e "${RED_COLOR}Failed to update package repositories${RESET_COLOR}"
        echo "[Error] Please check your internet connection."
        return 1
    fi
}

install_essential_packages() {
    """ Installs only the essential packages: python and android-tools.
    Returns 0 if all packages installed successfully, 1 otherwise.
    """
    echo -e "\n**Installing Essential Packages..."
    
    local packages=("python" "android-tools")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        echo -e "**Installing ${package}..."
        
        if pkg install -y "$package" &>/dev/null; then
            echo -e "**${package} Installation: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
        else
            echo -e "**${package} Installation: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        echo -e "${RED_COLOR}Failed to install: ${failed_packages[*]}${RESET_COLOR}"
        echo "[Error] Please install manually: pkg install ${failed_packages[*]}"
        echo -e "For support, visit: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
        return 1
    fi
    
    echo -e "**Essential Packages Installation: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
    return 0
}

verify_installations() {
    """ Verifies that Python and ADB are properly installed and accessible.
    Returns 0 if verification successful, 1 otherwise.
    """
    echo -e "\n**Verifying Installations..."
    
    # Check Python installation
    if command -v python3 &>/dev/null; then
        local python_version=$(python3 --version 2>/dev/null)
        echo -e "**Python Verification: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR} ($python_version)"
    elif command -v python &>/dev/null; then
        local python_version=$(python --version 2>/dev/null)
        echo -e "**Python Verification: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR} ($python_version)"
    else
        echo -e "**Python Verification: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        echo -e "${RED_COLOR}Python is not available${RESET_COLOR}"
        return 1
    fi
    
    # Check ADB installation
    if command -v adb &>/dev/null; then
        local adb_version=$(adb version 2>/dev/null | head -n1)
        echo -e "**ADB Verification: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR} ($adb_version)"
    else
        echo -e "**ADB Verification: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        echo -e "${RED_COLOR}ADB is not available${RESET_COLOR}"
        return 1
    fi
    
    return 0
}

download_debloater_files() {
    """ Downloads the debloater script and related files from GitHub.
    Returns 0 if successful, 1 otherwise.
    """
    echo -e "\n**Downloading Debloater Files..."
    
    # Remove existing installation if present
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${GREEN_COLOR}Removing existing installation...${RESET_COLOR}"
        rm -rf "$INSTALL_DIR"
    fi
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/$LISTS_DIR"
    
    # Download main script
    local script_url="${GITHUB_REPO}/raw/main/${SCRIPT_NAME}"
    
    if command -v curl &>/dev/null; then
        if curl -sL "$script_url" -o "$INSTALL_DIR/$SCRIPT_NAME"; then
            echo -e "**Debloater Script Download: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
        else
            echo -e "**Debloater Script Download: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
            echo -e "${RED_COLOR}Failed to download debloater script${RESET_COLOR}"
            return 1
        fi
    else
        echo -e "**Download Tool Check: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        echo -e "${RED_COLOR}curl is not available${RESET_COLOR}"
        return 1
    fi
    
    # Download bloatware lists (example for common brands)
    local lists=("xiaomi.txt" "samsung.txt" "oneplus.txt" "common.txt")
    
    for list_file in "${lists[@]}"; do
        local list_url="${GITHUB_REPO}/raw/main/lists/${list_file}"
        
        if curl -sL "$list_url" -o "$INSTALL_DIR/$LISTS_DIR/$list_file" 2>/dev/null; then
            echo -e "**${list_file} Download: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
        else
            echo -e "**${list_file} Download: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        fi
    done
    
    return 0
}

setup_debloater() {
    """ Sets up file permissions and creates the launcher script.
    Returns 0 if successful, 1 otherwise.
    """
    echo -e "\n**Setting Up Debloater..."
    
    # Make main script executable
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        echo -e "**Script Permissions: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
    else
        echo -e "**Script Permissions: ${RED_COLOR}UNSUCCESSFUL${RESET_COLOR}"
        echo -e "${RED_COLOR}Main script not found${RESET_COLOR}"
        return 1
    fi
    
    # Create launcher script
    cat > "$PREFIX/bin/debloat" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Universal Android Debloater Launcher

DEBLOATER_DIR="$HOME/android-debloater"
SCRIPT_PATH="$DEBLOATER_DIR/debloater.py"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "\033[91m[ERROR]\033[0m Debloater not found"
    echo "Please reinstall using the installation script."
    exit 1
fi

cd "$DEBLOATER_DIR"

if command -v python3 &>/dev/null; then
    python3 "$SCRIPT_PATH" "$@"
elif command -v python &>/dev/null; then
    python "$SCRIPT_PATH" "$@"
else
    echo -e "\033[91m[ERROR]\033[0m Python not available"
    exit 1
fi
EOF
    
    chmod +x "$PREFIX/bin/debloat"
    echo -e "**Launcher Creation: ${GREEN_COLOR}SUCCESSFUL${RESET_COLOR}"
    
    return 0
}

show_installation_complete() {
    """ Displays the installation completion message with usage instructions.
    """
    echo -e "\n${GREEN_COLOR}╔══════════════════════════════════════════════════════════════╗${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}                                                              ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}              Installation Complete Successfully!             ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}║${RESET_COLOR}                                                              ${GREEN_COLOR}║${RESET_COLOR}"
    echo -e "${GREEN_COLOR}╚══════════════════════════════════════════════════════════════╝${RESET_COLOR}"
    
    echo -e "\n**Usage Instructions:"
    echo -e "${GREEN_COLOR}1. ${RESET_COLOR}Connect your Android device via USB"
    echo -e "${GREEN_COLOR}2. ${RESET_COLOR}Enable USB debugging on your device"
    echo -e "${GREEN_COLOR}3. ${RESET_COLOR}Run: ${GREEN_COLOR}debloat${RESET_COLOR}"
    
    echo -e "\n**Installation Details:"
    echo -e "${GREEN_COLOR}~ Installation Directory:${RESET_COLOR} $INSTALL_DIR"
    echo -e "${GREEN_COLOR}~ Command:${RESET_COLOR} ${GREEN_COLOR}debloat${RESET_COLOR} (available from anywhere)"
    
    echo -e "\n**Support Information:"
    echo -e "${GREEN_COLOR}~ Telegram:${RESET_COLOR} ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "${GREEN_COLOR}~ Version:${RESET_COLOR} ${GREEN_COLOR}1.0${RESET_COLOR}"
    
    echo -e "\n${GREEN_COLOR}Happy Debloating! 🚀${RESET_COLOR}\n"
}

cleanup_on_failure() {
    """ Performs cleanup when installation fails.
    """
    echo -e "\n${RED_COLOR}Performing cleanup...${RESET_COLOR}"
    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
    [ -f "$PREFIX/bin/debloat" ] && rm -f "$PREFIX/bin/debloat"
}

main() {
    echo -e "\n** Universal Android Debloater - Installer **"
    echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
    echo -e "Author: TechGeekZ"
    echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
    echo -e "─────────────────────────────────────────────────────────────"
    
    # Trap for cleanup on failure
    trap 'echo -e "\n${RED_COLOR}Installation interrupted${RESET_COLOR}"; cleanup_on_failure; exit 1' INT TERM
    
    # Installation steps following debloater.py structure
    if ! check_termux_environment; then
        exit 1
    fi
    
    if ! update_termux_packages; then
        exit 1
    fi
    
    if ! install_essential_packages; then
        cleanup_on_failure
        exit 1
    fi
    
    if ! verify_installations; then
        cleanup_on_failure
        exit 1
    fi
    
    if ! download_debloater_files; then
        cleanup_on_failure
        exit 1
    fi
    
    if ! setup_debloater; then
        cleanup_on_failure
        exit 1
    fi
    
    show_installation_complete
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
