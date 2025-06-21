#!/data/data/com.termux/files/usr/bin/bash

# install.sh - Universal Android Bloatware Remover Setup Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat
# Repository: https://github.com/SPEED-OX/debloate

# ANSI color codes matching debloater.py design
RESET_COLOR='\033[0m'
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
TELEGRAM_COLOR='\033[38;2;37;150;190m'

# Repository configuration
REPO_URL="https://github.com/SPEED-OX/debloate"
DEST_DIR="$HOME/debloater"
SUPPORT_GROUP_URL="https://t.me/TechGeekZ_chat"

echo

if [ ! -d "$HOME/storage" ]; then
    echo -e "\nGrant permission: termux-setup-storage\nThen rerun the command.\n"
    exit 1
fi

arch=$(dpkg --print-architecture)
if [[ "$arch" != "aarch64" && "$arch" != "arm" ]]; then
    echo "Debloater does not support architecture $arch"
    exit 1
fi

debloaterusers="$PREFIX/bin/.debloaterusersok"

if [ ! -f "$debloaterusers" ]; then
    echo -ne "\rapt upgrade ..."
    apt upgrade > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
    curl -Is https://github.com/SPEED-OX/debloate/releases > /dev/null 2>&1
    touch "$debloaterusers"
fi

echo -ne "\rurl check ..."

main_repo=$(grep -E '^deb ' /data/data/com.termux/files/usr/etc/apt/sources.list | awk '{print $2}' | head -n 1)

curl -s --retry 4 $main_repo > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\nRequest to $main_repo failed. Please check your internet connection.\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\nThe $main_repo is blocked in your current country.\n"
    exit 35
fi

git_repo="https://raw.githubusercontent.com"

curl -s --retry 4 $git_repo > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\nRequest to $git_repo failed. Please check your internet connection.\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\nThe $git_repo is blocked in your current country.\n"
    exit 35
fi

echo -ne "\rapt update ..."
apt update > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")

charit=1
total=5
start_time=$(date +%s)

_progress() {
    charit=$((charit + 1))
    percentage=$((charit * 100 / total))
    echo -ne "\rProgress: $charit/$total ($percentage%)"
    if [ $percentage -eq 100 ]; then
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        echo -ne "\rProgress: $charit/$total ($percentage%) Took: $elapsed_time seconds"
    else
        echo -ne "\rProgress: $charit/$total ($percentage%)"
    fi
}

_progress

packages=(
    "python"
    "android-tools"
)

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

# Clone or download debloater repository
if [ -d "$DEST_DIR" ]; then
    rm -rf "$DEST_DIR"
fi

curl -s -L "$REPO_URL/archive/main.zip" -o /tmp/debloater.zip
if [ $? -eq 0 ]; then
    unzip -q /tmp/debloater.zip -d /tmp/
    mkdir -p "$DEST_DIR"
    cp -r /tmp/debloate-main/* "$DEST_DIR/"
    rm -rf /tmp/debloater.zip /tmp/debloate-main
    chmod +x "$DEST_DIR/debloater.py"
fi

_progress

# Create alias
alias_command="alias debloat='python3 $DEST_DIR/debloater.py'"
if ! grep -q "alias debloat=" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Universal Android Bloatware Remover alias" >> "$HOME/.bashrc"
    echo "$alias_command" >> "$HOME/.bashrc"
fi

_progress

echo

echo -e "\n${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
echo -e "${GREEN_COLOR}Version${RESET_COLOR}: ${GREEN_COLOR}1.0${RESET_COLOR}"
echo -e "Author: TechGeekZ"
echo -e "${TELEGRAM_COLOR}Telegram${RESET_COLOR}: ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
echo -e "${GREEN_COLOR}$(printf "%0.s─" {1..50})${RESET_COLOR}"
echo -e "\n${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
echo -e "\n${GREEN_COLOR}Usage:${RESET_COLOR} Type ${GREEN_COLOR}'debloat'${RESET_COLOR} from anywhere in Termux"
echo -e "\n${GREEN_COLOR}Support:${RESET_COLOR} ${TELEGRAM_COLOR}${SUPPORT_GROUP_URL}${RESET_COLOR}"
echo -e "${GREEN_COLOR}$(printf "%0.s─" {1..50})${RESET_COLOR}"

printf "\nuse command: \e[1;32mdebloat\e[0m\n\n"
