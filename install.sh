#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Installation Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat

# ANSI color codes matching the design
RESET_COLOR='\033[0m'
GREEN_COLOR='\033[92m'
RED_COLOR='\033[91m'
BLUE_COLOR='\033[94m'
YELLOW_COLOR='\033[93m'
CYAN_COLOR='\033[96m'

# Repository configuration
GITHUB_REPO="https://raw.githubusercontent.com/SPEED-OX/debloate"
SUPPORT_GROUP_URL="https://t.me/TechGeekZ_chat"

# Progress tracking variables
charit=0
total=12
start_time=$(date +%s)

# Progress display function
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
check_network() {
    echo -ne "\rurl check ..."
    
    # Check GitHub connectivity
    curl -s --retry 4 $GITHUB_REPO > /dev/null
    exit_code=$?
    
    if [ $exit_code -eq 6 ]; then
        echo -e "\nRequest to $GITHUB_REPO failed. Please check your internet connection.\n"
        exit 6
    elif [ $exit_code -eq 35 ]; then
        echo -e "\nThe $GITHUB_REPO is blocked in your current country.\n"
        exit 35
    fi
}

# System package updates
update_packages() {
    echo -ne "\rapt update ..."
    apt update > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
    _progress
    
    echo -ne "\rapt upgrade ..."
    apt upgrade -y > /dev/null 2> >(grep -v "apt does not have a stable CLI interface")
    _progress
}

# Essential package installation
install_packages() {
    packages=(
        "python3"
        "android-tools"
    )
    
    for package in "${packages[@]}"; do
        installed=$(apt policy "$package" 2>/dev/null | grep 'Installed' | awk '{print $2}')
        candidate=$(apt policy "$package" 2>/dev/null | grep 'Candidate' | awk '{print $2}')
        
        if [ "$installed" != "$candidate" ]; then
            pkg install "$package" -y >/dev/null 2>&1
        fi
        _progress
    done
}

# Python libraries installation
install_python_libs() {
    libs=(
        "requests"
        "colorama"
    )
    
    for lib in "${libs[@]}"; do
        installed_version=$(pip show "$lib" 2>/dev/null | grep Version | awk '{print $2}')
        
        if [ -z "$installed_version" ]; then
            pip install "$lib" -q
        else
            pip install --upgrade "$lib" -q
        fi
        _progress
    done
}

# Download main script
download_debloater() {
    curl -s "$GITHUB_REPO/main/debloater.py" -o "$PREFIX/bin/debloater" && chmod +x "$PREFIX/bin/debloater"
    _progress
}

# Download bloatware lists
download_lists() {
    # Create lists directory
    mkdir -p "$PREFIX/bin/lists"
    
    # Download brand-specific lists
    brands=("xiaomi" "samsung" "oneplus" "realme" "vivo" "oppo" "huawei" "common")
    
    for brand in "${brands[@]}"; do
        curl -s "$GITHUB_REPO/main/lists/${brand}.txt" -o "$PREFIX/bin/lists/${brand}.txt" 2>/dev/null
        _progress
    done
}

# Setup command aliases
setup_aliases() {
    # Add alias to .bashrc
    bashrc_file="$HOME/.bashrc"
    alias_line="alias debloat='python3 \$PREFIX/bin/debloater'"
    
    if ! grep -q "alias debloat=" "$bashrc_file" 2>/dev/null; then
        echo "" >> "$bashrc_file"
        echo "# Universal Android Bloatware Remover" >> "$bashrc_file"
        echo "$alias_line" >> "$bashrc_file"
    fi
    
    # Source bashrc
    source "$bashrc_file" 2>/dev/null || true
    _progress
}

# Main installation function
main() {
    echo
    echo -e "${GREEN_COLOR}** Universal Android Bloatware Remover Setup **${RESET_COLOR}"
    echo -e "${CYAN_COLOR}Version: 1.0${RESET_COLOR}"
    echo -e "Author: TechGeekZ"
    echo -e "${BLUE_COLOR}Telegram: $SUPPORT_GROUP_URL${RESET_COLOR}"
    echo "────────────────────────────────────────────────"
    echo
    
    # Execute installation steps
    check_network
    update_packages
    install_packages
    install_python_libs
    download_debloater
    download_lists
    setup_aliases
    
    echo
    echo "────────────────────────────────────────────────"
    echo
    echo -e "${GREEN_COLOR}** INSTALLATION COMPLETED SUCCESSFULLY **${RESET_COLOR}"
    echo
    echo -e "${CYAN_COLOR}Usage:${RESET_COLOR} Type '${GREEN_COLOR}debloat${RESET_COLOR}' from anywhere in Termux"
    echo
    echo -e "${CYAN_COLOR}Support:${RESET_COLOR} ${BLUE_COLOR}$SUPPORT_GROUP_URL${RESET_COLOR}"
    echo
    echo "────────────────────────────────────────────────"
    echo
    echo -e "use command: ${GREEN_COLOR}debloat${RESET_COLOR}"
    echo
}

# Execute main function
main "$@"
