#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover Install Script
# Repo: https://github.com/SPEED-OX/debloate
# Support: https://t.me/your_support_group

set -e

REPO_URL="https://github.com/SPEED-OX/debloate"
SCRIPT_DIR="$HOME/debloate"
ALIAS_CMD='debloate'
SUPPORT_URL="https://t.me/your_support_group"  # Change to your actual support link

progress_bar() {
    local duration=$1
    local i=0
    local bar=""
    while [ $i -le $duration ]; do
        bar+="#"
        printf "\r[%-${duration}s] %d%%" "$bar" $(( (i * 100) / duration ))
        sleep 0.15
        ((i++))
    done
    echo ""
}

error_exit() {
    echo
    echo "[ERROR] $1"
    echo "For help, visit: $SUPPORT_URL"
    exit 1
}

echo "------------------------------------------"
echo " Universal Android Bloatware Remover Setup"
echo "------------------------------------------"
echo

# Step 1: Update & upgrade packages (auto-y, silent)
echo "[1/7] Updating and upgrading Termux packages..."
yes | pkg update -y > /dev/null 2>&1 || error_exit "Failed to update packages."
yes | pkg upgrade -y > /dev/null 2>&1 || error_exit "Failed to upgrade packages."
progress_bar 8

# Step 2: Install required packages (auto-y, silent)
echo "[2/7] Installing required packages (python, git, curl)..."
yes | pkg install python git curl -y > /dev/null 2>&1 || error_exit "Failed to install python/git/curl."
progress_bar 8

# Step 3: Install Android tools if not present
if ! command -v adb &>/dev/null; then
    echo "[3/7] Installing Android platform-tools (adb)..."
    yes | pkg install android-tools -y > /dev/null 2>&1 || error_exit "Failed to install android-tools."
    progress_bar 8
else
    echo "[3/7] Android platform-tools (adb) already installed."
fi

# Step 4: Install Termux:API if not present
if ! command -v termux-toast &>/dev/null; then
    echo "[4/7] Installing Termux:API..."
    yes | pkg install termux-api -y > /dev/null 2>&1 || error_exit "Failed to install Termux:API."
    progress_bar 8
    echo
    echo "[ACTION REQUIRED]"
    echo "Please install the Termux:API companion app from the Play Store or F-Droid and grant all required permissions."
    echo "- Play Store: https://play.google.com/store/apps/details?id=com.termux.api"
    echo "- F-Droid:    https://f-droid.org/packages/com.termux.api"
    echo "After installing, re-run this script if you encounter issues."
    echo
fi

# Step 5: Request Storage Permission
echo "[5/7] Checking storage permission..."
if [ ! -d "$HOME/storage/shared" ]; then
    echo "Requesting storage permission via termux-setup-storage..."
    termux-setup-storage || error_exit "Failed to request storage permission. Please grant it manually and re-run the script."
    echo "Please grant storage permission in the popup. Press [ENTER] to continue after granting."
    read
    if [ ! -d "$HOME/storage/shared" ]; then
        error_exit "Storage permission not granted. Please grant permission and re-run the script."
    fi
fi

# Step 6: Clone or update the repo
if [ -d "$SCRIPT_DIR" ]; then
    echo "[6/7] Updating existing debloate repository..."
    cd "$SCRIPT_DIR"
    git pull origin main > /dev/null 2>&1 || error_exit "Failed to update the repository."
else
    echo "[6/7] Cloning debloate repository..."
    git clone "$REPO_URL" "$SCRIPT_DIR" > /dev/null 2>&1 || error_exit "Failed to clone the repository."
fi
progress_bar 8

# Step 7: Add alias to .bashrc/.zshrc
ALIAS_STR="alias $ALIAS_CMD='python $SCRIPT_DIR/debloater.py'"
if ! grep -Fxq "$ALIAS_STR" "$HOME/.bashrc"; then
    echo "$ALIAS_STR" >> "$HOME/.bashrc"
    echo "Added alias to ~/.bashrc."
fi
if [ -f "$HOME/.zshrc" ] && ! grep -Fxq "$ALIAS_STR" "$HOME/.zshrc"; then
    echo "$ALIAS_STR" >> "$HOME/.zshrc"
    echo "Added alias to ~/.zshrc."
fi

echo
echo "------------------------------------------------------------"
echo " Setup complete."
echo " To use the tool, restart your shell or run: source ~/.bashrc"
echo " Then simply type '$ALIAS_CMD' anywhere in Termux to launch."
echo
echo "For help or troubleshooting, visit: $SUPPORT_URL"
echo "------------------------------------------------------------"
