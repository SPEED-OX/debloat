#!/data/data/com.termux/files/usr/bin/bash

# Debloate Installer for Termux
# ---------------------------------
# This script installs all necessary dependencies, checks permissions,
# and sets up the 'debloate' command as a global alias.

set -e

REPO_URL="https://github.com/SPEED-OX/debloate"
SCRIPT_DIR="$HOME/debloate"
ALIAS_CMD='debloate'
SUPPORT_URL="https://t.me/TechGeekZ_chat"  # Change to your actual support link

# -------- Progress bar function --------
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

# Step 1: Update & install packages
echo "[1/6] Updating package lists and upgrading Termux..."
pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1
progress_bar 8

echo "[2/6] Installing required packages (python, git, curl)..."
pkg install -y python git curl > /dev/null 2>&1
progress_bar 8

# Step 2: Install Android tools if not present
if ! command -v adb &>/dev/null; then
    echo "[3/6] Installing Android platform-tools (adb)..."
    pkg install -y android-tools > /dev/null 2>&1
    progress_bar 8
else
    echo "[3/6] Android platform-tools (adb) already installed."
fi

# Step 3: Install Termux:API if not present
if ! command -v termux-toast &>/dev/null; then
    echo "[4/6] Installing Termux:API..."
    pkg install -y termux-api > /dev/null 2>&1
    progress_bar 8
    echo ""
    echo "Please ensure the Termux:API companion app is installed from F-Droid or Play Store."
    echo "If not installed, open this link on your device:"
    echo "https://play.google.com/store/apps/details?id=com.termux.api"
    echo "https://f-droid.org/packages/com.termux.api"
    echo ""
fi

# Step 4: Request Storage Permission
echo "[5/6] Checking storage permission..."
if [ ! -d "$HOME/storage" ]; then
    echo "Requesting storage permission..."
    termux-setup-storage
    echo "Please grant permission in the popup. Press [ENTER] to continue after granting."
    read
fi

# Step 5: Clone or update the repo
if [ -d "$SCRIPT_DIR" ]; then
    echo "[6/6] Updating existing debloate repository..."
    cd "$SCRIPT_DIR"
    git pull origin main > /dev/null 2>&1
else
    echo "[6/6] Cloning debloate repository..."
    git clone "$REPO_URL" "$SCRIPT_DIR" > /dev/null 2>&1
fi
progress_bar 8

# Step 6: Add alias to .bashrc/.zshrc
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
