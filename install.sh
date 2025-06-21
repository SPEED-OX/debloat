#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Installation Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat

# ANSI color codes matching exact display
GREEN_COLOR='\033[92m'
RESET_COLOR='\033[0m'
RED_COLOR='\033[91m'

# Repository configuration
GITHUB_REPO="https://raw.githubusercontent.com/SPEED-OX/debloate"
REPO_ZIP="https://github.com/SPEED-OX/debloate/archive/refs/heads/main.zip"

# Progress tracking variables
charit=0
total=12
start_time=$(date +%s)

# Progress display function - prints only once per step
_progress() {
    charit=$((charit + 1))
    percentage=$((charit * 100 / total))
    echo -ne "\rProgress: $charit/$total ($percentage%)"
    if [ $percentage -eq 100 ]; then
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        echo -ne "\rProgress: $charit/$total ($percentage%) Took: $elapsed_time seconds"
        echo
    fi
}

# Network connectivity check
echo -ne "\rurl check ..."
curl -s --retry 4 $GITHUB_REPO > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\nRequest to $GITHUB_REPO failed. Please check your internet connection.\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\nThe $GITHUB_REPO is blocked in your current country.\n"
    exit 35
fi

echo -ne "\rapt update ..."
apt update > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
_progress

echo -ne "\rapt upgrade ..."
apt upgrade -y > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
_progress

echo -ne "\rinstalling python3 ..."
pkg install python3 -y > /dev/null 2>&1
_progress

echo -ne "\rinstalling android-tools ..."
pkg install android-tools -y > /dev/null 2>&1
_progress

echo -ne "\rdownloading repository ..."
curl -L -s "$REPO_ZIP" -o /tmp/debloate-main.zip
_progress

echo -ne "\rextracting files ..."
cd /tmp && unzip -q debloate-main.zip
_progress

echo -ne "\rinstalling debloater ..."
cp debloate-main/debloater.py "$PREFIX/bin/debloater"
chmod +x "$PREFIX/bin/debloater"
_progress

echo -ne "\rinstalling lists ..."
mkdir -p "$PREFIX/bin/lists"
cp -r debloate-main/lists/* "$PREFIX/bin/lists/" 2>/dev/null || true
_progress

echo -ne "\rcreating alias ..."
# Create proper alias in .bashrc
if ! grep -q "alias debloat=" "$HOME/.bashrc" 2>/dev/null; then
    echo 'alias debloat="python3 $PREFIX/bin/debloater"' >> "$HOME/.bashrc"
fi
# Automatically source .bashrc to activate alias immediately
source "$HOME/.bashrc" 2>/dev/null || true
# Also create the alias in current session
alias debloat="python3 $PREFIX/bin/debloater"
_progress

echo -ne "\rcleaning up ..."
rm -rf /tmp/debloate-main /tmp/debloate-main.zip
_progress

echo -ne "\rvalidating installation ..."
if [ -x "$PREFIX/bin/debloater" ]; then
    _progress
else
    echo -e "\n${RED_COLOR}Installation failed${RESET_COLOR}"
    exit 1
fi

echo -ne "\rfinalizing setup ..."
_progress

echo
echo
echo -e "${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
echo -e "${GREEN_COLOR}Version: 1.0${RESET_COLOR}"
echo "Author: TechGeekZ"
echo "Telegram: https://t.me/TechGeekZ_chat"
echo "$(printf '─%.0s' {1..50})"
echo
echo
echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
echo
echo -e "${GREEN_COLOR}Usage:${RESET_COLOR} Type '${GREEN_COLOR}debloat${RESET_COLOR}' from anywhere in Termux"
echo
echo "$(printf '─%.0s' {1..50})"
echo
printf "use command: \e[1;32mdebloat\e[0m\n\n"
