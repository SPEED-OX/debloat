#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Termux Installation Script
# Author: TechGeekZ
# Version: 1.0

# ANSI color codes matching debloater.py style
BRAND_COLORS_XIAOMI='\033[38;5;208m'  # Orange
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
YELLOW_COLOR='\033[93m'
CYAN_COLOR='\033[96m'
RESET_COLOR='\033[0m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'  # Hex #2596be

# Configuration
GITHUB_REPO="https://raw.githubusercontent.com/YourUsername/universal-android-debloater/main"
INSTALL_DIR="$HOME/android-debloater"
DEBLOATER_USERS="$PREFIX/bin/.debloaterusersok"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "\n${RED_COLOR}This installer is designed for Termux only!${RESET_COLOR}"
    echo -e "${RED_COLOR}Please install Termux from F-Droid and run this script inside Termux.${RESET_COLOR}\n"
    exit 1
fi

# User tracking (similar to original script)
if [ ! -f "$DEBLOATER_USERS" ]; then
    echo -ne "\r${GREEN_COLOR}apt upgrade${RESET_COLOR} ..."
    apt upgrade > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
    curl -Is https://github.com/YourUsername/universal-android-debloater/releases/download/tracking/totalusers > /dev/null 2>&1
    touch "$DEBLOATER_USERS"
fi

echo -ne "\r${GREEN_COLOR}url check${RESET_COLOR} ..."

# Check main repository connection
main_repo=$(grep -E '^deb ' /data/data/com.termux/files/usr/etc/apt/sources.list | awk '{print $2}' | head -n 1)

curl -s --retry 4 $main_repo > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\n${RED_COLOR}Request to $main_repo failed. Please check your internet connection.${RESET_COLOR}\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\n${RED_COLOR}The $main_repo is blocked in your current country.${RESET_COLOR}\n"
    exit 35
fi

# Check GitHub connection
git_repo="https://raw.githubusercontent.com"

curl -s --retry 4 $git_repo > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\n${RED_COLOR}Request to $git_repo failed. Please check your internet connection.${RESET_COLOR}\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\n${RED_COLOR}The $git_repo is blocked in your current country.${RESET_COLOR}\n"
    exit 35
fi

echo -ne "\r${GREEN_COLOR}apt update${RESET_COLOR} ..."
apt update > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")

# Progress tracking system (from original script)
charit=1
total=12
start_time=$(date +%s)

_progress() {
    charit=$((charit + 1))
    percentage=$((charit * 100 / total))
    if [ $percentage -eq 100 ]; then
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        echo -ne "\r${GREEN_COLOR}Progress: $charit/$total ($percentage%) Took: $elapsed_time seconds${RESET_COLOR}"
    else
        echo -ne "\r${GREEN_COLOR}Progress: $charit/$total ($percentage%)${RESET_COLOR}"
    fi
}

_progress

# Essential packages for debloater
packages=(
    "python"
    "android-tools"
    "curl"
    "wget"
    "git"
)

# Install/update packages
for package in "${packages[@]}"; do
    installed=$(apt policy "$package" 2>/dev/null | grep 'Installed' | awk '{print $2}')
    candidate=$(apt policy "$package" 2>/dev/null | grep 'Candidate' | awk '{print $2}')
    
    if [ "$installed" != "$candidate" ]; then
        apt download "$package" >/dev/null 2>&1
        dpkg --force-overwrite -i "${package}"*.deb >/dev/null 2>&1
        rm -f "${package}"*.deb
    fi
    
    _progress
done

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/lists"

# Download main debloater script
curl -s "$GITHUB_REPO/debloater.py" -o "$INSTALL_DIR/debloater.py"
chmod +x "$INSTALL_DIR/debloater.py"

_progress

# Download bloatware lists
brand_lists=(
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
    "asus.txt"
    "lenovo.txt"
    "google.txt"
    "nothing.txt"
    "common.txt"
)

for list_file in "${brand_lists[@]}"; do
    curl -s "$GITHUB_REPO/lists/$list_file" -o "$INSTALL_DIR/lists/$list_file" 2>/dev/null
done

_progress

# Create executable wrapper script
cat > "$PREFIX/bin/debloater" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover Wrapper
# This script allows running debloater from anywhere in Termux

DEBLOATER_DIR="$HOME/android-debloater"
DEBLOATER_SCRIPT="$DEBLOATER_DIR/debloater.py"

# ANSI color codes
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
RESET_COLOR='\033[0m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Check if debloater is installed
if [ ! -f "$DEBLOATER_SCRIPT" ]; then
    echo -e "${RED_COLOR}[ERROR]${RESET_COLOR} Debloater not found at $DEBLOATER_SCRIPT"
    echo -e "Please run the installer first or reinstall the debloater."
    echo -e "For support, visit: ${TELEGRAM_COLOR}https://t.me/TechGeekZ_chat${RESET_COLOR}"
    exit 1
fi

# Check if Python is available
if ! command -v python >/dev/null 2>&1; then
    echo -e "${RED_COLOR}[ERROR]${RESET_COLOR} Python is not installed or not in PATH"
    echo -e "Please install Python: ${GREEN_COLOR}pkg install python${RESET_COLOR}"
    exit 1
fi

# Check if ADB is available
if ! command -v adb >/dev/null 2>&1; then
    echo -e "${RED_COLOR}[ERROR]${RESET_COLOR} ADB is not installed or not in PATH"
    echo -e "Please install Android Tools: ${GREEN_COLOR}pkg install android-tools${RESET_COLOR}"
    exit 1
fi

# Change to debloater directory and run the script
cd "$DEBLOATER_DIR"
python "$DEBLOATER_SCRIPT" "$@"
EOF

chmod +x "$PREFIX/bin/debloater"

_progress

# Create alias in .bashrc for persistent access
if ! grep -q "alias debloater=" "$HOME/.bashrc" 2>/dev/null; then
    echo "alias debloater='$PREFIX/bin/debloater'" >> "$HOME/.bashrc"
fi

_progress

# Verify installation
echo

# Print installation summary with debloater.py styling
echo -e "\n${GREEN_COLOR}** Universal Android Bloatware Remover **${RESET_COLOR}"
echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
echo -e "Author: TechGeekZ"
echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}https://t.me/TechGeekZ_chat${RESET_COLOR}"
echo -e "${GREEN_COLOR}${'─' * 50}${RESET_COLOR}"

# Installation verification
if [ -f "$INSTALL_DIR/debloater.py" ]; then
    echo -e "${GREEN_COLOR}✓${RESET_COLOR} Main script installed successfully"
else
    echo -e "${RED_COLOR}✗${RESET_COLOR} Main script installation failed"
fi

if [ -d "$INSTALL_DIR/lists" ]; then
    list_count=$(find "$INSTALL_DIR/lists" -name "*.txt" 2>/dev/null | wc -l)
    echo -e "${GREEN_COLOR}✓${RESET_COLOR} Bloatware lists installed ($list_count files)"
else
    echo -e "${RED_COLOR}✗${RESET_COLOR} Bloatware lists installation failed"
fi

if [ -x "$PREFIX/bin/debloater" ]; then
    echo -e "${GREEN_COLOR}✓${RESET_COLOR} Command shortcut created"
else
    echo -e "${RED_COLOR}✗${RESET_COLOR} Command shortcut creation failed"
fi

if command -v python >/dev/null 2>&1; then
    echo -e "${GREEN_COLOR}✓${RESET_COLOR} Python is available"
else
    echo -e "${RED_COLOR}✗${RESET_COLOR} Python installation failed"
fi

if command -v adb >/dev/null 2>&1; then
    echo -e "${GREEN_COLOR}✓${RESET_COLOR} ADB is available"
else
    echo -e "${RED_COLOR}✗${RESET_COLOR} ADB installation failed"
fi

echo -e "${GREEN_COLOR}${'─' * 50}${RESET_COLOR}"

# Usage instructions
echo -e "\n${GREEN_COLOR}** Usage Instructions **${RESET_COLOR}"
echo -e "${GREEN_COLOR}1.${RESET_COLOR} Connect your Android device via USB"
echo -e "${GREEN_COLOR}2.${RESET_COLOR} Enable USB Debugging on your device"
echo -e "${GREEN_COLOR}3.${RESET_COLOR} Run: ${YELLOW_COLOR}debloater${RESET_COLOR}"
echo -e "\n${GREEN_COLOR}** Additional Commands **${RESET_COLOR}"
echo -e "${GREEN_COLOR}•${RESET_COLOR} Check connected devices: ${YELLOW_COLOR}adb devices${RESET_COLOR}"
echo -e "${GREEN_COLOR}•${RESET_COLOR} Manual execution: ${YELLOW_COLOR}cd $INSTALL_DIR && python debloater.py${RESET_COLOR}"
echo -e "${GREEN_COLOR}•${RESET_COLOR} Reinstall: ${YELLOW_COLOR}curl -fsSL [installer-url] | bash${RESET_COLOR}"

echo -e "\n${GREEN_COLOR}** Installation Complete! **${RESET_COLOR}"
echo -e "Installation directory: ${CYAN_COLOR}$INSTALL_DIR${RESET_COLOR}"
echo -e "Support: ${TELEGRAM_COLOR}https://t.me/TechGeekZ_chat${RESET_COLOR}"

printf "\n${GREEN_COLOR}Use command: ${YELLOW_COLOR}debloater${RESET_COLOR}\n\n"
