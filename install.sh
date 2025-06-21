#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Installation Script
# GitHub: https://github.com/SPEED-OX/debloate
# This script will setup debloater.py in Termux with all required dependencies

echo

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress tracking
current_step=0
total_steps=8

# Enhanced progress bar function
show_progress() {
    current_step=$((current_step + 1))
    percentage=$((current_step * 100 / total_steps))
    filled=$((percentage / 2))
    
    printf "\r${GREEN}["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $((50 - filled)) | tr ' ' '░'
    printf "] %d%% (%d/%d)${NC}" $percentage $current_step $total_steps
    
    if [ $percentage -eq 100 ]; then
        echo
    fi
}

echo -e "${BLUE}Universal Android Bloatware Remover - Setup${NC}"
echo -e "${BLUE}============================================${NC}"
echo

# Step 1: Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt update > /dev/null 2>&1
show_progress

# Step 2: Upgrade existing packages
echo -e "\n${YELLOW}Upgrading packages...${NC}"
apt upgrade -y > /dev/null 2>&1
show_progress

# Step 3: Install Python3
echo -e "\n${YELLOW}Installing Python3...${NC}"
pkg install -y python > /dev/null 2>&1
show_progress

# Step 4: Install Android Tools (ADB)
echo -e "\n${YELLOW}Installing Android Tools...${NC}"
pkg install -y android-tools > /dev/null 2>&1
show_progress

# Step 5: Create debloater directory
echo -e "\n${YELLOW}Creating debloater directory...${NC}"
mkdir -p "$HOME/debloater"
mkdir -p "$HOME/debloater/lists"
show_progress

# Step 6: Download debloater.py from GitHub
echo -e "\n${YELLOW}Downloading debloater.py...${NC}"
curl -s -L -o "$HOME/debloater/debloater.py" "https://raw.githubusercontent.com/SPEED-OX/debloate/main/debloater.py"
show_progress

# Step 7: Download bloatware lists
echo -e "\n${YELLOW}Downloading bloatware lists...${NC}"
# Download common list
curl -s -L -o "$HOME/debloater/lists/common.txt" "https://raw.githubusercontent.com/SPEED-OX/debloate/main/lists/common.txt" 2>/dev/null || echo "# Common bloatware list" > "$HOME/debloater/lists/common.txt"

# Download brand-specific lists
brands=("xiaomi" "samsung" "oneplus" "realme" "vivo" "oppo" "huawei" "honor" "motorola" "nokia")
for brand in "${brands[@]}"; do
    curl -s -L -o "$HOME/debloater/lists/${brand}.txt" "https://raw.githubusercontent.com/SPEED-OX/debloate/main/lists/${brand}.txt" 2>/dev/null
done
show_progress

# Step 8: Make debloater.py executable and create alias
echo -e "\n${YELLOW}Setting up executable permissions and alias...${NC}"
chmod +x "$HOME/debloater/debloater.py"

# Create alias in .bashrc
if ! grep -q "alias debloater=" "$HOME/.bashrc" 2>/dev/null; then
    echo 'alias debloater="python3 $HOME/debloater/debloater.py"' >> "$HOME/.bashrc"
fi

# Create direct executable link
ln -sf "$HOME/debloater/debloater.py" "$PREFIX/bin/debloater" 2>/dev/null
show_progress

echo
echo -e "${GREEN}✓ Installation completed successfully!${NC}"
echo
echo -e "${BLUE}Usage:${NC}"
echo -e "  ${GREEN}debloater${NC}          - Run from anywhere using alias"
echo -e "  ${GREEN}python3 ~/debloater/debloater.py${NC} - Direct execution"
echo
echo -e "${BLUE}Location:${NC}"
echo -e "  Script: ${GREEN}~/debloater/debloater.py${NC}"
echo -e "  Lists:  ${GREEN}~/debloater/lists/${NC}"
echo
echo -e "${YELLOW}Note:${NC} Make sure to enable USB debugging and connect your Android device before running the debloater."
echo -e "${YELLOW}Restart Termux or run 'source ~/.bashrc' to use the 'debloater' command.${NC}"
echo
