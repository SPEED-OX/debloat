#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Debloater - Termux Installation Script
# Author: TechGeekZ
# Description: Automated installation script for setting up the debloater in Termux
# Support: https://t.me/TechGeekZ_chat

# Color definitions for enhanced user experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration variables
GITHUB_REPO="https://github.com/YourUsername/android-debloater"
INSTALL_DIR="$HOME/android-debloater"
SCRIPT_NAME="debloater.py"
LISTS_DIR="lists"

# Function to print colored headers
print_header() {
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}${BOLD}          Universal Android Debloater - Installer            ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}                    Version 1.0                              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${PURPLE}                  Author: TechGeekZ                          ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${BLUE}            Telegram: https://t.me/TechGeekZ_chat            ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update and upgrade Termux packages
update_termux() {
    print_status "Updating Termux package repositories..."
    
    # Update package lists without confirmation
    if pkg update -y >/dev/null 2>&1; then
        print_success "Package repositories updated successfully"
    else
        print_error "Failed to update package repositories"
        return 1
    fi
    
    print_status "Upgrading installed packages..."
    
    # Upgrade packages without confirmation
    if pkg upgrade -y >/dev/null 2>&1; then
        print_success "Packages upgraded successfully"
    else
        print_warning "Some packages may not have been upgraded properly"
    fi
}

# Function to install required packages
install_dependencies() {
    print_status "Installing required dependencies..."
    
    local packages=("python" "android-tools" "git" "wget" "curl")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        print_status "Installing $package..."
        
        if pkg install -y "$package" >/dev/null 2>&1; then
            print_success "$package installed successfully"
        else
            print_error "Failed to install $package"
            failed_packages+=("$package")
        fi
    done
    
    # Check if any packages failed to install
    if [ ${#failed_packages[@]} -gt 0 ]; then
        print_error "The following packages failed to install: ${failed_packages[*]}"
        print_error "Please install them manually using: pkg install ${failed_packages[*]}"
        return 1
    fi
    
    print_success "All dependencies installed successfully"
}

# Function to verify ADB installation
verify_adb() {
    print_status "Verifying ADB installation..."
    
    if command_exists adb; then
        local adb_version=$(adb version 2>/dev/null | head -n1)
        print_success "ADB is properly installed: $adb_version"
        return 0
    else
        print_error "ADB installation verification failed"
        return 1
    fi
}

# Function to verify Python installation
verify_python() {
    print_status "Verifying Python installation..."
    
    if command_exists python3; then
        local python_version=$(python3 --version 2>/dev/null)
        print_success "Python is properly installed: $python_version"
        return 0
    elif command_exists python; then
        local python_version=$(python --version 2>/dev/null)
        print_success "Python is properly installed: $python_version"
        return 0
    else
        print_error "Python installation verification failed"
        return 1
    fi
}

# Function to clone or download the debloater repository
download_debloater() {
    print_status "Downloading Universal Android Debloater..."
    
    # Remove existing installation if present
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Existing installation found. Removing..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Try to clone with git first
    if command_exists git; then
        print_status "Cloning repository using Git..."
        if git clone "$GITHUB_REPO" "$INSTALL_DIR" >/dev/null 2>&1; then
            print_success "Repository cloned successfully"
            return 0
        else
            print_warning "Git clone failed, trying alternative download method..."
        fi
    fi
    
    # Alternative download method using wget or curl
    print_status "Downloading repository archive..."
    mkdir -p "$INSTALL_DIR"
    
    local archive_url="${GITHUB_REPO}/archive/main.zip"
    local temp_file="/tmp/debloater.zip"
    
    # Try wget first, then curl
    if command_exists wget; then
        if wget -q "$archive_url" -O "$temp_file"; then
            print_status "Extracting archive..."
            if unzip -q "$temp_file" -d "/tmp/" && mv "/tmp/android-debloater-main/"* "$INSTALL_DIR/"; then
                rm -f "$temp_file"
                rm -rf "/tmp/android-debloater-main"
                print_success "Repository downloaded and extracted successfully"
                return 0
            fi
        fi
    elif command_exists curl; then
        if curl -sL "$archive_url" -o "$temp_file"; then
            print_status "Extracting archive..."
            if unzip -q "$temp_file" -d "/tmp/" && mv "/tmp/android-debloater-main/"* "$INSTALL_DIR/"; then
                rm -f "$temp_file"
                rm -rf "/tmp/android-debloater-main"
                print_success "Repository downloaded and extracted successfully"
                return 0
            fi
        fi
    fi
    
    print_error "Failed to download the debloater repository"
    return 1
}

# Function to set up file permissions
setup_permissions() {
    print_status "Setting up file permissions..."
    
    # Make the main script executable
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        print_success "Made $SCRIPT_NAME executable"
    else
        print_error "$SCRIPT_NAME not found in installation directory"
        return 1
    fi
    
    # Set appropriate permissions for the lists directory
    if [ -d "$INSTALL_DIR/$LISTS_DIR" ]; then
        chmod -R 644 "$INSTALL_DIR/$LISTS_DIR"/*.txt 2>/dev/null
        print_success "Set appropriate permissions for bloatware lists"
    else
        print_warning "Lists directory not found, creating it..."
        mkdir -p "$INSTALL_DIR/$LISTS_DIR"
    fi
}

# Function to create a convenient launcher script
create_launcher() {
    print_status "Creating launcher script..."
    
    local launcher_path="$PREFIX/bin/debloater"
    
    cat > "$launcher_path" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Universal Android Debloater Launcher Script

DEBLOATER_DIR="$HOME/android-debloater"
SCRIPT_PATH="$DEBLOATER_DIR/debloater.py"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "\033[0;31m[ERROR]\033[0m Debloater not found at $SCRIPT_PATH"
    echo "Please run the installer again or check the installation."
    exit 1
fi

cd "$DEBLOATER_DIR"

# Check if python3 is available, fallback to python
if command -v python3 >/dev/null 2>&1; then
    python3 "$SCRIPT_PATH" "$@"
elif command -v python >/dev/null 2>&1; then
    python "$SCRIPT_PATH" "$@"
else
    echo -e "\033[0;31m[ERROR]\033[0m Python is not installed or not in PATH"
    exit 1
fi
EOF
    
    chmod +x "$launcher_path"
    print_success "Launcher script created at $launcher_path"
    print_status "You can now run the debloater from anywhere using: ${GREEN}debloater${NC}"
}

# Function to display usage instructions
show_usage_instructions() {
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}${BOLD}                    Installation Complete!                   ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${GREEN}${BOLD}Usage Instructions:${NC}"
    echo -e "${WHITE}1.${NC} Connect your Android device via USB"
    echo -e "${WHITE}2.${NC} Enable USB Debugging on your device"
    echo -e "${WHITE}3.${NC} Run the debloater using one of these methods:"
    echo -e "   ${YELLOW}•${NC} ${GREEN}debloater${NC} (from anywhere)"
    echo -e "   ${YELLOW}•${NC} ${GREEN}cd $INSTALL_DIR && python3 $SCRIPT_NAME${NC}"
    
    echo -e "\n${BLUE}${BOLD}Important Notes:${NC}"
    echo -e "${WHITE}•${NC} Make sure to authorize ADB connection on your device"
    echo -e "${WHITE}•${NC} Always backup your device before removing system apps"
    echo -e "${WHITE}•${NC} Some apps may require a device reboot to take effect"
    
    echo -e "\n${PURPLE}${BOLD}Support:${NC}"
    echo -e "${WHITE}•${NC} Telegram: ${CYAN}https://t.me/TechGeekZ_chat${NC}"
    echo -e "${WHITE}•${NC} Installation Directory: ${YELLOW}$INSTALL_DIR${NC}"
    
    echo -e "\n${GREEN}${BOLD}Happy Debloating! 🚀${NC}\n"
}

# Function to perform cleanup on failure
cleanup_on_failure() {
    print_warning "Cleaning up due to installation failure..."
    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
    [ -f "$PREFIX/bin/debloater" ] && rm -f "$PREFIX/bin/debloater"
}

# Main installation function
main() {
    # Clear screen and show header
    clear
    print_header
    
    # Check if running in Termux
    if [ ! -d "/data/data/com.termux" ]; then
        print_error "This script is designed to run in Termux environment only!"
        exit 1
    fi
    
    print_status "Starting Universal Android Debloater installation..."
    
    # Step 1: Update Termux
    if ! update_termux; then
        print_error "Failed to update Termux packages"
        exit 1
    fi
    
    # Step 2: Install dependencies
    if ! install_dependencies; then
        print_error "Failed to install required dependencies"
        exit 1
    fi
    
    # Step 3: Verify installations
    if ! verify_adb || ! verify_python; then
        print_error "Dependency verification failed"
        exit 1
    fi
    
    # Step 4: Download debloater
    if ! download_debloater; then
        print_error "Failed to download debloater"
        cleanup_on_failure
        exit 1
    fi
    
    # Step 5: Setup permissions
    if ! setup_permissions; then
        print_error "Failed to setup file permissions"
        cleanup_on_failure
        exit 1
    fi
    
    # Step 6: Create launcher
    if ! create_launcher; then
        print_error "Failed to create launcher script"
        cleanup_on_failure
        exit 1
    fi
    
    # Step 7: Show completion message
    show_usage_instructions
}

# Trap to handle script interruption
trap 'echo -e "\n${RED}Installation interrupted by user${NC}"; cleanup_on_failure; exit 1' INT TERM

# Run main function
main "$@"
