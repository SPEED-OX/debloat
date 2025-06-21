#!/data/data/com.termux/files/usr/bin/bash

# Universal Android Bloatware Remover - Installation Script
# Author: TechGeekZ
# Telegram: https://t.me/TechGeekZ_chat

echo

if [ ! -d "/data/data/com.termux.api" ]; then
    echo -e "\ncom.termux.api app is not installed\nPlease install it first\n"
    exit 1
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
total=12
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
    "python3"
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

libs=(
    "requests"
    "colorama"
)

for lib in "${libs[@]}"; do
    installed_version=$(pip show "$lib" 2>/dev/null | grep Version | awk '{print $2}')
    latest_version=$(pip index versions "$lib" 2>/dev/null | grep 'LATEST:' | awk '{print $2}')
    
    if [ -z "$installed_version" ]; then
        pip install "$lib" -q
    elif [ "$installed_version" != "$latest_version" ]; then
        pip install --upgrade "$lib" -q
    fi
    
    _progress
done

curl -s "https://raw.githubusercontent.com/SPEED-OX/debloate/main/debloater.py" -o "$PREFIX/bin/debloater" && chmod +x "$PREFIX/bin/debloater"

_progress

# Create lists directory
mkdir -p "$PREFIX/bin/lists"

# Download bloatware lists
brands=("xiaomi" "samsung" "oneplus" "realme" "vivo" "oppo" "huawei" "common")

for brand in "${brands[@]}"; do
    curl -s "https://raw.githubusercontent.com/SPEED-OX/debloate/main/lists/${brand}.txt" -o "$PREFIX/bin/lists/${brand}.txt" 2>/dev/null
    _progress
done

# Create proper alias in .bashrc
echo 'alias debloat="python3 $PREFIX/bin/debloater"' >> ~/.bashrc

_progress

echo

curl -L -s https://raw.githubusercontent.com/SPEED-OX/debloate/main/CHANGELOG.md | tac | awk '/^#/{exit} {print "\033[0;34m" $0 "\033[0m"}' | tac

printf "\nuse command: \e[1;32mdebloat\e[0m\n\n"
