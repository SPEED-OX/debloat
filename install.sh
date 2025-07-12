#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Termux Installation Script
# Author: TechGeekZ
# Version: 1.0

# ANSI color codes matching debloater.py style
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
YELLOW_COLOR='\033[93m'
CYAN_COLOR='\033[96m'
RESET_COLOR='\033[0m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'  # Hex #2596be

# Configuration
GITHUB_REPO="https://github.com/SPEED-OX/debloat"  # Updated repository link
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
    curl -Is https://github.com/SPEED-OX/debloat/releases/download/tracking/totalusers > /dev/null 2>&1
    touch "$DEBLOATER_USERS"
fi

echo -ne "\r${GREEN_COLOR}url check${RESET_COLOR} ..."

# Check main repository connection
main_repo=$(grep -E '^deb ' /data/data/com.termux/files/usr/etc/apt/sources.list | awk '{print $2}' | head -n 1)

if ! curl -s --retry 4 $main_repo > /dev/null; then
    echo -e "\n${RED_COLOR}Request to $main_repo failed. Please check your internet connection.${RESET_COLOR}\n"
    exit 1
fi

# Check GitHub connection
if ! curl -s --retry 4 https://raw.githubusercontent.com > /dev/null; then
    echo -e "\n${RED_COLOR}GitHub connection failed. Please check your internet connection.${RESET_COLOR}\n"
    exit 1
fi

echo -ne "\r${GREEN_COLOR}apt update${RESET_COLOR} ..."
if ! apt update > /dev/null 2>&1; then
    echo -e "\n${RED_COLOR}apt update failed. Please check your internet connection.${RESET_COLOR}"
    exit 1
fi

echo -ne "\r${GREEN_COLOR}apt upgrade${RESET_COLOR} ..."
if ! apt upgrade -y > /dev/null 2>&1; then
    echo -e "\n${YELLOW_COLOR}[WARNING]${RESET_COLOR} apt upgrade failed, continuing with installation..."
fi

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
if ! pkg install python3 -y >/dev/null 2>&1; then
    echo -e "\n${RED_COLOR}Failed to install python3. Please check your internet connection.${RESET_COLOR}"
    exit 1
fi

# Install android-tools
_progress
if ! pkg install android-tools -y >/dev/null 2>&1; then
    echo -e "\n${RED_COLOR}Failed to install android-tools. Please check your internet connection.${RESET_COLOR}"
    exit 1
fi

# Install unzip if not available
if ! command -v unzip >/dev/null 2>&1; then
    pkg install unzip -y >/dev/null 2>&1
fi

# Download and extract repository as zip
_progress
cd "$HOME"
if ! curl -L -s "${GITHUB_REPO}/archive/refs/heads/main.zip" -o debloate.zip; then
    echo -e "\n${RED_COLOR}Failed to download repository.${RESET_COLOR}"
    exit 1
fi

_progress
if ! unzip -q debloate.zip; then
    echo -e "\n${RED_COLOR}Failed to extract repository.${RESET_COLOR}"
    exit 1
fi

# Create installation directory and copy files
_progress
rm -rf "$INSTALL_DIR" 2>/dev/null
mkdir -p "$INSTALL_DIR"

# Copy main script
if [ -f "$HOME/debloat-main/debloater.py" ]; then
    cp "$HOME/debloat-main/debloater.py" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/debloater.py"
else
    echo -e "\n${RED_COLOR}debloater.py not found in downloaded files.${RESET_COLOR}"
    exit 1
fi

# Copy lists directory
if [ -d "$HOME/debloat-main/lists" ]; then
    cp -r "$HOME/debloat-main/lists" "$INSTALL_DIR/"
fi

# Clean up temporary files (including ZIP)
rm -rf "$HOME/debloate.zip" "$HOME/debloat-main"

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

# Print installation summary
echo
echo -e "${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
echo -e "Author: TechGeekZ"
echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}https://t.me/TechGeekZ_chat${RESET_COLOR}"
echo -e "${GREEN_COLOR}──────────────────────────────────────────────────${RESET_COLOR}"
echo
echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
echo -e "use command~ ${GREEN_COLOR}debloat${RESET_COLOR}"
