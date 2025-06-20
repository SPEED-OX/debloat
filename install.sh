#!/bin/bash

# Debloater Project Installer Script
# Automatically updates packages, installs requirements, checks permissions

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress bar function
show_progress() {
    local duration=${1}
    local message=${2}
    
    echo -ne "${BLUE}${message}${NC}"
    for ((i=0; i<=duration; i++)); do
        echo -ne "\r${BLUE}${message} ["
        for ((j=0; j<i*50/duration; j++)); do echo -ne "#"; done
        for ((j=i*50/duration; j<50; j++)); do echo -ne "-"; done
        echo -ne "] ${i}%${NC}"
        sleep 0.1
    done
    echo -e "\n${GREEN}✓ ${message} completed${NC}"
}

# Check if running in Termux
check_termux() {
    if command -v termux-setup-storage >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Running in Termux environment${NC}"
        return 0
    else
        echo -e "${RED}✗ This script must be run in Termux${NC}"
        exit 1
    fi
}

# Update package repositories and upgrade
update_packages() {
    echo -e "${YELLOW}Updating package repositories...${NC}"
    show_progress 20 "Updating repositories"
    pkg update -y >/dev/null 2>&1
    
    echo -e "${YELLOW}Upgrading packages...${NC}"
    show_progress 30 "Upgrading packages"
    pkg upgrade -y >/dev/null 2>&1
}

# Install required packages
install_requirements() {
    local packages=("git" "curl" "wget" "python" "nodejs" "openssh" "rsync")
    
    for package in "${packages[@]}"; do
        if ! dpkg -s "$package" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $package...${NC}"
            show_progress 15 "Installing $package"
            pkg install -y "$package" >/dev/null 2>&1
        else
            echo -e "${GREEN}✓ $package already installed${NC}"
        fi
    done
}

# Check storage permission
check_storage_permission() {
    echo -e "${YELLOW}Checking storage permissions...${NC}"
    
    if [ ! -d "$HOME/storage" ]; then
        echo -e "${YELLOW}Setting up storage access...${NC}"
        termux-setup-storage
        
        # Wait for user to grant permission
        echo -e "${BLUE}Please grant storage permission when prompted${NC}"
        sleep 3
        
        # Verify storage access
        if [ -d "$HOME/storage/shared" ]; then
            echo -e "${GREEN}✓ Storage permission granted${NC}"
        else
            echo -e "${RED}✗ Storage permission denied or failed${NC}"
            echo -e "${YELLOW}Please manually run 'termux-setup-storage' and grant permission${NC}"
            exit 1
        fi
    else
        # Test if we can actually access storage
        if ls "$HOME/storage/shared" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Storage access already configured${NC}"
        else
            echo -e "${YELLOW}Storage permission may need to be re-granted${NC}"
            echo -e "${BLUE}Go to Settings > Apps > Termux > Permissions and toggle Storage permission${NC}"
        fi
    fi
}

# Check if Termux:API is installed
check_termux_api() {
    echo -e "${YELLOW}Checking Termux:API installation...${NC}"
    
    # Check if termux-api package is installed
    if dpkg -s termux-api >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Termux:API package is installed${NC}"
        
        # Test if API actually works
        if command -v termux-battery-status >/dev/null 2>&1; then
            # Try to get battery status to verify API works
            if termux-battery-status >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Termux:API is fully functional${NC}"
            else
                echo -e "${YELLOW}⚠ Termux:API package installed but app may be missing${NC}"
                echo -e "${BLUE}Please install Termux:API app from F-Droid or Play Store${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}Installing Termux:API package...${NC}"
        show_progress 10 "Installing termux-api"
        pkg install -y termux-api >/dev/null 2>&1
        
        echo -e "${BLUE}Note: You also need to install Termux:API app from F-Droid or Play Store${NC}"
    fi
}

# Clone or update debloater project
setup_debloater() {
    local repo_url="https://github.com/your-username/debloater.git"  # Replace with actual repo
    local project_dir="$HOME/debloater"
    
    if [ -d "$project_dir" ]; then
        echo -e "${YELLOW}Updating existing debloater project...${NC}"
        cd "$project_dir"
        show_progress 15 "Pulling latest changes"
        git pull >/dev/null 2>&1
    else
        echo -e "${YELLOW}Cloning debloater project...${NC}"
        show_progress 25 "Cloning repository"
        git clone "$repo_url" "$project_dir" >/dev/null 2>&1
        cd "$project_dir"
    fi
    
    # Make scripts executable
    if [ -f "debloater.sh" ]; then
        chmod +x debloater.sh
        echo -e "${GREEN}✓ Made debloater.sh executable${NC}"
    fi
}

# Create useful aliases
setup_aliases() {
    echo -e "${YELLOW}Setting up convenient aliases...${NC}"
    
    if ! grep -q "alias debloat=" "$HOME/.bashrc" 2>/dev/null; then
        echo "alias debloat='cd \$HOME/debloater && ./debloater.sh'" >> "$HOME/.bashrc"
        echo "alias update-debloater='cd \$HOME/debloater && git pull'" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added convenient aliases to .bashrc${NC}"
        echo -e "${BLUE}Use 'debloat' command to run the debloater${NC}"
    else
        echo -e "${GREEN}✓ Aliases already configured${NC}"
    fi
}

# Main installation function
main() {
    echo -e "${BLUE}=== Debloater Project Installer ===${NC}"
    echo -e "${BLUE}This script will set up everything needed for the debloater project${NC}\n"
    
    # Run all checks and installations
    check_termux
    update_packages
    install_requirements
    check_storage_permission
    check_termux_api
    setup_debloater
    setup_aliases
    
    echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}"
    echo -e "${BLUE}You can now run the debloater using: ${YELLOW}debloat${NC}"
    echo -e "${BLUE}Or navigate to: ${YELLOW}cd ~/debloater && ./debloater.sh${NC}"
    echo -e "${BLUE}To update in the future: ${YELLOW}update-debloater${NC}"
}

# Handle script interruption
trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM

# Run main function
main
