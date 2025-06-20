#!/data/data/com.termux/files/usr/bin/bash

set -e

REPO_URL="https://github.com/SPEED-OX/debloate"
SCRIPT_DIR="$HOME/debloate"
ALIAS_CMD='debloate'
SUPPORT_URL="https://t.me/TechGeekZ_chat"  # Change to your actual support link

# --- Helper: Error and exit ---
error_exit() {
    echo
    echo "[ERROR] $1"
    echo "For help, visit: $SUPPORT_URL"
    exit 1
}

# --- Progress Bar ---
progress_bar() {
    local duration=$1
    local i=0
    local bar=""
    while [ $i -le $duration ]; do
        bar+="#"
        printf "\r[%-${duration}s] %d%%" "$bar" $(( (i * 100) / duration ))
        sleep 0.2
        ((i++))
    done
    echo ""
}

echo "------------------------------------------"
echo " Universal Android Bloatware Remover Setup"
echo "------------------------------------------"
echo ""

# 1. Update packages
echo "[1/6] Updating package lists and upgrading Termux..."
if ! pkg update -y; then
    error_exit "Failed to update package lists. Check your internet connection or Termux repositories."
fi
if ! pkg upgrade -y; then
    error_exit "Failed to upgrade packages."
fi
progress_bar 8

# 2. Install required packages
echo "[2/6] Installing required packages (python, git, curl)..."
if ! pkg install -y python git curl; then
    error_exit "Failed to install python, git, or curl."
fi
progress_bar 8

# 3. Install Android tools if not present
if ! command -v adb &>/dev/null; then
    echo "[3/6] Installing Android platform-tools (adb)..."
    if ! pkg install -y android-tools; then
        error_exit "Failed to install android-tools."
    fi
    progress_bar 8
else
    echo "[3/6] Android platform-tools (adb) already installed."
fi

# 4. Install Termux:API if not present
if ! command -v termux-toast &>/dev/null; then
    echo "[4/6] Installing Termux:API..."
    if ! pkg install -y termux-api; then
        error_exit "Failed to install Termux:API."
    fi
    progress_bar 8
    echo ""
    echo "[ACTION REQUIRED]"
    echo "Please install the Termux:API companion app from the Play Store or F-Droid."
    echo "Open this link on your device: https://play.google.com/store/apps/details?id=com.termux.api"
    echo "Or: https://f-droid.org/packages/com.termux.api"
    echo "After installing, re-run this script if you encounter issues."
fi

# 5. Request Storage Permission
echo "[5/6] Checking storage permission..."
if [ ! -d "$HOME/storage/shared" ]; then
    echo "Requesting storage permission via termux-setup-storage..."
    if ! termux-setup-storage; then
        error_exit "Failed to request storage permission. Please grant it manually and re-run the script."
    fi
    echo "Please grant storage permission in the popup. Press [ENTER] to continue after granting."
    read
    if [ ! -d "$HOME/storage/shared" ]; then
        error_exit "Storage permission not granted. Please grant permission and re-run the script."
    fi
fi

# 6. Clone or update the repo
if [ -d "$SCRIPT_DIR" ]; then
    echo "[6/6] Updating existing debloate repository..."
    cd "$SCRIPT_DIR"
    if ! git pull origin main; then
        error_exit "Failed to update the repository."
    fi
else
    echo "[6/6] Cloning debloate repository..."
    if ! git clone "$REPO_URL" "$SCRIPT_DIR"; then
        error_exit "Failed to clone the repository."
    fi
fi
progress_bar 8

# 7. Add alias
ALIAS_STR="alias $ALIAS_CMD='python $SCRIPT_DIR/debloater.py'"
if ! grep -Fxq "$ALIAS_STR" "$HOME/.bashrc"; then
    echo "$ALIAS_STR" >> "$HOME/.bashrc"
    echo "Added alias to ~/.bashrc."
fi
if [ -f "$HOME/.zshrc" ] && ! grep -Fxq "$ALIAS_STR" "$HOME/.zshrc"; then
    echo "$ALIAS_STR" >> "$HOME/.zshrc"
    echo "Added alias to ~/.zshrc."
fi

echo ""
echo "------------------------------------------------------------"
echo " Setup complete."
echo " To use the tool, restart your shell or run: source ~/.bashrc"
echo " Then simply type '$ALIAS_CMD' anywhere in Termux to launch."
echo ""
echo "For help or troubleshooting, visit: $SUPPORT_URL"
echo "------------------------------------------------------------"
