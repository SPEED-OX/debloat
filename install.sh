#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Debloater - Professional Installation Script
# Author: TechGeekZ
# Support: https://t.me/TechGeekZ_chat

# Clean color scheme - Professional appearance
HEADER='\033[1;36m'     # Bright Cyan for headers
SUCCESS='\033[1;32m'    # Bright Green for success
ERROR='\033[1;31m'      # Bright Red for errors
INFO='\033[1;34m'       # Bright Blue for info
WARNING='\033[1;33m'    # Bright Yellow for warnings
RESET='\033[0m'         # Reset color
BOLD='\033[1m'          # Bold text

# Configuration
GITHUB_REPO="https://github.com/YourUsername/android-debloater"
INSTALL_DIR="$HOME/android-debloater"
SCRIPT_NAME="debloater.py"

# Professional header with clean design
show_header() {
    clear
    echo -e "${HEADER}${BOLD}"
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│                                                         │"
    echo "│         Universal Android Debloater v1.0               │"
    echo "│                                                         │"
    echo "│         Professional Installation Script                │"
    echo "│                                                         │"
    echo "│         Author: TechGeekZ                               │"
    echo "│         Support: t.me/TechGeekZ_chat                    │"
    echo "│                                                         │"
    echo "└─────────────────────────────────────────────────────────┘"
    echo -e "${RESET}\n"
}

# Clean status messages
log_info() {
    echo -e "${INFO}▶${RESET} $1"
}

log_success() {
    echo -e "${SUCCESS}✓${RESET} $1"
}

log_error() {
    echo -e "${ERROR}✗${RESET} $1"
}

log_warning() {
    echo -e "${WARNING}⚠${RESET} $1"
}

# Check if running in Termux
check_environment() {
    if [ ! -d "/data/data/com.termux" ]; then
        log_error "This installer requires Termux environment"
        exit 1
    fi
}

# Update package repositories
update_packages() {
    log_info "Updating package repositories..."
    
    if pkg update -y &>/dev/null; then
        log_success "Package repositories updated"
    else
        log_error "Failed to update repositories"
        exit 1
    fi
}

# Install only essential packages
install_essentials() {
    log_info "Installing essential packages..."
    
    # Only install what's absolutely necessary
    local packages=("python" "android-tools")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        
        if pkg install -y "$package" &>/dev/null; then
            log_success "$package installed"
        else
            log_error "Failed to install $package"
            echo -e "${WARNING}Manual installation required:${RESET} pkg install $package"
            exit 1
        fi
    done
}

# Verify installations
verify_tools() {
    log_info "Verifying installations..."
    
    # Check Python
    if command -v python3 &>/dev/null || command -v python &>/dev/null; then
        log_success "Python verified"
    else
        log_error "Python installation failed"
        exit 1
    fi
    
    # Check ADB
    if command -v adb &>/dev/null; then
        log_success "ADB verified"
    else
        log_error "ADB installation failed"
        exit 1
    fi
}

# Download debloater (simplified)
download_debloater() {
    log_info "Downloading debloater..."
    
    # Remove existing installation
    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Simple download approach - adjust URL as needed
    local script_url="${GITHUB_REPO}/raw/main/debloater.py"
    
    if command -v curl &>/dev/null; then
        if curl -sL "$script_url" -o "$INSTALL_DIR/$SCRIPT_NAME"; then
            log_success "Debloater downloaded"
        else
            log_error "Download failed"
            exit 1
        fi
    else
        log_error "Download tool not available"
        exit 1
    fi
}

# Set up permissions and create launcher
setup_launcher() {
    log_info "Setting up launcher..."
    
    # Make script executable
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Create simple launcher
    cat > "$PREFIX/bin/debloat" << EOF
#!/data/data/com.termux/files/usr/bin/bash
cd "$INSTALL_DIR"
if command -v python3 &>/dev/null; then
    python3 "$SCRIPT_NAME" "\$@"
else
    python "$SCRIPT_NAME" "\$@"
fi
EOF
    
    chmod +x "$PREFIX/bin/debloat"
    log_success "Launcher created"
}

# Show completion message
show_completion() {
    echo -e "\n${HEADER}${BOLD}"
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│                                                         │"
    echo "│              Installation Complete!                     │"
    echo "│                                                         │"
    echo "└─────────────────────────────────────────────────────────┘"
    echo -e "${RESET}\n"
    
    echo -e "${SUCCESS}${BOLD}Usage:${RESET}"
    echo -e "  ${INFO}debloat${RESET}  - Run from anywhere"
    echo -e "\n${INFO}${BOLD}Setup:${RESET}"
    echo -e "  1. Connect Android device via USB"
    echo -e "  2. Enable USB Debugging"
    echo -e "  3. Run: ${SUCCESS}debloat${RESET}"
    
    echo -e "\n${WARNING}${BOLD}Support:${RESET} t.me/TechGeekZ_chat"
    echo ""
}

# Cleanup on failure
cleanup() {
    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
    [ -f "$PREFIX/bin/debloat" ] && rm -f "$PREFIX/bin/debloat"
}

# Main installation process
main() {
    # Trap for cleanup
    trap 'echo -e "\n${ERROR}Installation cancelled${RESET}"; cleanup; exit 1' INT TERM
    
    # Installation steps
    show_header
    check_environment
    
    log_info "Starting installation process..."
    echo ""
    
    update_packages
    install_essentials
    verify_tools
    download_debloater
    setup_launcher
    
    echo ""
    show_completion
}

# Run installation
main "$@"
