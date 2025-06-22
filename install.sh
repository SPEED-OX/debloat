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
LIGHT_BLUE_COLOR='\033[38;5;117m'

# Configuration
GITHUB_REPO="https://github.com/SPEED-OX/debloate"
INSTALL_DIR="$HOME/android-debloater"
DEBLOATER_USERS="$PREFIX/bin/.debloaterusersok"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "\n${RED_COLOR}This installer is designed for Termux only!${RESET_COLOR}"
    echo -e "${RED_COLOR}Please install Termux from F-Droid and run this script inside Termux.${RESET_COLOR}\n"
    exit 1
fi

# User tracking and initial upgrade
if [ ! -f "$DEBLOATER_USERS" ]; then
    echo -ne "\r${GREEN_COLOR}apt upgrade${RESET_COLOR} ..."
    apt upgrade -y > /dev/null 2>&1
    curl -Is https://github.com/SPEED-OX/debloate/releases/download/tracking/totalusers > /dev/null 2>&1
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
apt update > /dev/null 2>&1

echo -ne "\r${GREEN_COLOR}apt upgrade${RESET_COLOR} ..."
apt upgrade -y > /dev/null 2>&1

# Progress tracking system
charit=0
total=5
start_time=$(date +%s)

_progress() {
    charit=$((charit + 1))
    percentage=$((charit * 100 / total))
    if [ $percentage -eq 100 ]; then
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        echo -ne "\rProgress: $charit/$total ($percentage%) Took: $elapsed_time seconds"
    else
        echo -ne "\rProgress: $charit/$total ($percentage%)"
    fi
}

# Install python3
_progress
pkg install python3 -y >/dev/null 2>&1

# Install android-tools
_progress
pkg install android-tools -y >/dev/null 2>&1

# Install unzip if not available
if ! command -v unzip >/dev/null 2>&1; then
    pkg install unzip -y >/dev/null 2>&1
fi

# Download and extract repository as zip
_progress
cd "$HOME"
curl -L -s "${GITHUB_REPO}/archive/refs/heads/main.zip" -o debloate.zip

# Extract zip file
unzip -q debloate.zip

# Create installation directory and copy files
_progress
rm -rf "$INSTALL_DIR" 2>/dev/null
mkdir -p "$INSTALL_DIR"

# Copy main script
if [ -f "$HOME/debloate-main/debloater.py" ]; then
    cp "$HOME/debloate-main/debloater.py" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/debloater.py"
fi

# Copy lists directory
if [ -d "$HOME/debloate-main/lists" ]; then
    cp -r "$HOME/debloate-main/lists" "$INSTALL_DIR/"
fi

# Clean up temporary files (including ZIP)
rm -rf "$HOME/debloate.zip" "$HOME/debloate-main"

# Create executable wrapper script
cat > "$PREFIX/bin/debloat" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover Wrapper
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
if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED_COLOR}[ERROR]${RESET_COLOR} Python is not installed or not in PATH"
    echo -e "Please install Python: ${GREEN_COLOR}pkg install python3${RESET_COLOR}"
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

# Use python3 if available, otherwise python
if command -v python3 >/dev/null 2>&1; then
    python3 "$DEBLOATER_SCRIPT" "$@"
else
    python "$DEBLOATER_SCRIPT" "$@"
fi
EOF

chmod +x "$PREFIX/bin/debloat"

# Create alias in .bashrc for persistent access
_progress
if ! grep -q "alias debloat=" "$HOME/.bashrc" 2>/dev/null; then
    echo "alias debloat='$PREFIX/bin/debloat'" >> "$HOME/.bashrc"
fi

# Print installation summary with exact styling from the image
echo
echo -e "${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
echo -e "Author: TechGeekZ"
echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}https://t.me/TechGeekZ_chat${RESET_COLOR}"
echo -e "${GREEN_COLOR}$(printf '─%.0s' {1..66})${RESET_COLOR}"
echo
echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
echo -e "use command~ ${GREEN_COLOR}debloat${RESET_COLOR}"
