#!/bin/bash

# Universal Android Bloatware Remover - Termux Installation Script
# This script automatically sets up the debloater tool in Termux environment

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Repository configuration
REPO_URL="https://raw.githubusercontent.com/SPEED-OX/debloate/main"
INSTALL_DIR="$HOME/debloater"
LISTS_DIR="$INSTALL_DIR/lists"

# Support information
SUPPORT_URL="https://t.me/TechGeekZ_chat"

echo -e "\n${CYAN}** Universal Android Bloatware Remover - Termux Setup **${RESET}"
echo -e "${GREEN}Author: TechGeekZ${RESET}"
echo -e "${TELEGRAM_COLOR}Telegram: $SUPPORT_URL${RESET}"
echo -e "$(printf '─%.0s' {1..60})"

# Function to print status messages
print_status() {
    echo -e "\n${BLUE}[INFO]${RESET} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to download file with error handling
download_file() {
    local url="$1"
    local output="$2"
    local description="$3"
    
    print_status "Downloading $description..."
    if curl -fsSL "$url" -o "$output"; then
        print_success "$description downloaded successfully"
        return 0
    else
        print_error "Failed to download $description from $url"
        return 1
    fi
}

# Update and upgrade Termux packages
print_status "Updating Termux package lists..."
if apt update -y >/dev/null 2>&1; then
    print_success "Package lists updated"
else
    print_warning "Package update had some issues, continuing..."
fi

print_status "Upgrading Termux packages..."
if apt upgrade -y >/dev/null 2>&1; then
    print_success "Packages upgraded"
else
    print_warning "Package upgrade had some issues, continuing..."
fi

# Install required packages
print_status "Installing required packages..."

# Install android-tools (includes adb)
if ! command_exists adb; then
    print_status "Installing android-tools..."
    if apt install -y android-tools >/dev/null 2>&1; then
        print_success "android-tools installed"
    else
        print_error "Failed to install android-tools"
        exit 1
    fi
else
    print_success "android-tools already installed"
fi

# Install Python3
if ! command_exists python3; then
    print_status "Installing Python3..."
    if apt install -y python3 >/dev/null 2>&1; then
        print_success "Python3 installed"
    else
        print_error "Failed to install Python3"
        exit 1
    fi
else
    print_success "Python3 already installed"
fi

# Install curl if not present
if ! command_exists curl; then
    print_status "Installing curl..."
    if apt install -y curl >/dev/null 2>&1; then
        print_success "curl installed"
    else
        print_error "Failed to install curl"
        exit 1
    fi
else
    print_success "curl already installed"
fi

# Create installation directory
print_status "Creating installation directory..."
if mkdir -p "$INSTALL_DIR" "$LISTS_DIR"; then
    print_success "Installation directories created"
else
    print_error "Failed to create installation directories"
    exit 1
fi

# Download main script
if ! download_file "$REPO_URL/debloater.py" "$INSTALL_DIR/debloater.py" "main debloater script"; then
    exit 1
fi

# Make the script executable
print_status "Setting executable permissions..."
if chmod +x "$INSTALL_DIR/debloater.py"; then
    print_success "Script permissions set"
else
    print_error "Failed to set script permissions"
    exit 1
fi

# Download bloatware lists
print_status "Downloading bloatware lists..."

# List of known brand files to download
BRAND_FILES=(
    "common.txt"
    "xiaomi.txt"
    "samsung.txt"
    "oneplus.txt"
    "realme.txt"
    "oppo.txt"
    "vivo.txt"
    "huawei.txt"
    "honor.txt"
    "motorola.txt"
    "nokia.txt"
    "lg.txt"
    "sony.txt"
    "htc.txt"
    "asus.txt"
    "lenovo.txt"
    "meizu.txt"
    "tcl.txt"
    "alcatel.txt"
    "google.txt"
    "nothing.txt"
    "fairphone.txt"
)

# Download each brand file (continue even if some fail)
downloaded_count=0
for brand_file in "${BRAND_FILES[@]}"; do
    if download_file "$REPO_URL/lists/$brand_file" "$LISTS_DIR/$brand_file" "$brand_file"; then
        ((downloaded_count++))
    else
        print_warning "Could not download $brand_file (may not exist in repository)"
    fi
done

print_success "Downloaded $downloaded_count bloatware list files"

# Create alias in .bashrc
print_status "Setting up 'debloat' command alias..."

# Remove existing alias if present
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/alias debloat=/d' "$HOME/.bashrc"
fi

# Add new alias
echo "alias debloat='python3 $INSTALL_DIR/debloater.py'" >> "$HOME/.bashrc"

# Also create a direct executable script for immediate use
cat > "$HOME/../usr/bin/debloat" << EOF
#!/bin/bash
python3 "$INSTALL_DIR/debloater.py" "\$@"
EOF

chmod +x "$HOME/../usr/bin/debloat"

print_success "Command alias 'debloat' created"

# Verify ADB installation
print_status "Verifying ADB installation..."
if command_exists adb; then
    ADB_VERSION=$(adb version 2>/dev/null | head -n1)
    print_success "ADB is ready: $ADB_VERSION"
else
    print_error "ADB installation verification failed"
    exit 1
fi

# Create usage instructions
cat > "$INSTALL_DIR/README.md" << EOF
# Universal Android Bloatware Remover

## Usage Instructions

### Quick Start
1. Enable USB Debugging on your Android device
2. Connect your device via USB
3. Run the command: \`debloat\`

### Commands
- \`debloat\` - Run the bloatware remover
- \`adb devices\` - Check connected devices

### Requirements
- Android device with USB Debugging enabled
- USB connection to Termux device
- Authorized ADB connection

### Support
For support or feature requests, visit: $SUPPORT_URL

### File Locations
- Main script: $INSTALL_DIR/debloater.py
- Bloatware lists: $LISTS_DIR/
- This guide: $INSTALL_DIR/README.md
EOF

# Final setup completion
echo -e "\n$(printf '─%.0s' {1..60})"
print_success "Installation completed successfully!"
echo -e "\n${GREEN}Setup Summary:${RESET}"
echo -e "  ${CYAN}•${RESET} Android tools (ADB) installed"
echo -e "  ${CYAN}•${RESET} Python3 environment ready"
echo -e "  ${CYAN}•${RESET} Debloater script downloaded"
echo -e "  ${CYAN}•${RESET} Bloatware lists updated"
echo -e "  ${CYAN}•${RESET} Command alias 'debloat' created"

echo -e "\n${YELLOW}Next Steps:${RESET}"
echo -e "  ${CYAN}1.${RESET} Enable USB Debugging on your Android device"
echo -e "  ${CYAN}2.${RESET} Connect your device via USB"
echo -e "  ${CYAN}3.${RESET} Restart Termux or run: ${GREEN}source ~/.bashrc${RESET}"
echo -e "  ${CYAN}4.${RESET} Run the command: ${GREEN}debloat${RESET}"

echo -e "\n${BLUE}Additional Commands:${RESET}"
echo -e "  ${GREEN}adb devices${RESET}     - Check connected devices"
echo -e "  ${GREEN}debloat${RESET}         - Run the bloatware remover"

echo -e "\n${TELEGRAM_COLOR}For support, visit: $SUPPORT_URL${RESET}"
echo -e "$(printf '─%.0s' {1..60})"

# Source bashrc to make alias available immediately (if running interactively)
if [[ $- == *i* ]]; then
    source "$HOME/.bashrc" 2>/dev/null || true
fi

print_success "You can now use the 'debloat' command!"
