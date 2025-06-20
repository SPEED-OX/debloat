#!/data/data/com.termux/files/usr/bin/bash

# Function to print messages
function print_message() {
    echo -e "\n\033[1;34m$1\033[0m"
}

# Create the main debloater directory
print_message "Creating the debloater directory structure..."
mkdir -p ~/debloater/lists

# Create sample bloatware lists (you can replace these with your actual files later)
cat <<EOF > ~/debloater/lists/realme.txt
# Sample bloatware list for Realme
AppName pm uninstall ... com.realme.bloatware
AnotherApp pm uninstall ... com.realme.anotherbloat
EOF

cat <<EOF > ~/debloater/lists/xiaomi.txt
# Sample bloatware list for Xiaomi
AppName pm uninstall ... com.xiaomi.bloatware
AnotherApp ➡️ com.xiaomi.anotherbloat
EOF

# Create the debloater.py file
cat <<EOF > ~/debloater/debloater.py
#!/usr/bin/env python3

"""
Universal Android Bloatware Remover
-----------------------------------
This script detects the connected Android device's brand and uses the corresponding
bloatware list to assist the user in uninstalling, disabling, enabling, or reinstalling apps.
"""

import os
import re
import subprocess
import sys

SUPPORT_GROUP_URL = "https://t.me/your_support_group"  # Replace with your actual support link

def get_device_brand():
    """Attempts to detect the Android device brand using adb."""
    try:
        result = subprocess.run(
            ['adb', 'shell', 'getprop', 'ro.product.brand'],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            print(f"[Error] adb returned code {result.returncode}: {result.stderr.strip()}")
            return None
        brand = result.stdout.strip().lower()
        if not brand:
            print("[Error] Device brand could not be determined (empty result from adb).")
            return None
        print(f"[Info] Detected device brand: {brand}")
        return brand
    except Exception as e:
        print(f"[Exception] Brand detection failed: {e}")
        return None

def find_brand_file(lists_dir, brand):
    """Looks for a bloatware list file corresponding to the given brand."""
    files = [f for f in os.listdir(lists_dir) if f.endswith('.txt')]
    if not files:
        print("[Error] No bloatware lists found in the lists/ directory.")
        sys.exit(1)
    if not brand:
        return None
    for f in files:
        if f.startswith(brand):
            print(f"[Info] Using list: {f} for brand: {brand}")
            return os.path.join(lists_dir, f)
    print(f"[Notice] No list found for detected brand '{brand}'.")
    print(f"This brand is currently unsupported or pending update.\n"
          f"For assistance or to request support, visit: {SUPPORT_GROUP_URL}\n")
    return None

def manual_brand_file_selection(lists_dir):
    """Allows the user to manually select a bloatware list file."""
    files = [f for f in os.listdir(lists_dir) if f.endswith('.txt')]
    print("Available bloatware lists:")
    for idx, f in enumerate(files):
        print(f"{idx+1}. {f.replace('.txt','')}")
    while True:
        try:
            idx = int(input("Select a brand by number: ").strip()) - 1
            if 0 <= idx < len(files):
                return os.path.join(lists_dir, files[idx])
            else:
                print("Invalid selection. Please enter a valid number.")
        except Exception:
            print("Invalid input. Please enter a number corresponding to the list.")

def parse_bloatware_file(filepath):
    """Parses the specified bloatware list file, extracting tuples of (app_name, package_name)."""
    apps = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            match = re.match(r'(.+?)(?:\s+pm\s+\w+[\w\s\-–—]+)?\s+([a-zA-Z0-9_. ]+)$', line)
            if match:
                app, package = match.group(1), match.group(2)
                apps.append((app.strip(), package.strip()))
                continue
            arrow_match = re.match(r'(.+?)\s*[➡️]\s*([a-zA-Z0-9_. ]+)$', line)
            if arrow_match:
                app, package = arrow_match.group(1), arrow_match.group(2)
                apps.append((app.strip(), package.strip()))
                continue
            package_only = re.match(r'^([a-zA-Z0-9_.]+)(? :\s*-\s*.+)?$', line)
            if package_only:
                package = package_only.group(1)
                app = package
                apps.append((app.strip(), package.strip()))
    return apps

def choose_app_and_action(apps):
    """Presents the list of apps and prompts the user to select one or all, then choose the desired action."""
    print("\nAvailable applications:")
    for idx, (app, package) in enumerate(apps):
        print(f"{idx+1}. {app} ({package})")
    print("0. [Batch] Select ALL applications")
    while True:
        selected = input("Enter application number (or 0 for all): ").strip()
        if selected == '0':
            indices = list(range(len(apps)))
            break
        try:
            idx = int(selected) - 1
            if 0 <= idx < len(apps):
                indices = [idx]
                break
            else:
                print("Invalid selection. Please enter a valid number.")
        except Exception:
            print("Invalid input. Please enter a numeric value.")
    print("\nChoose an action:")
    print("1. Uninstall (keep data)")
    print("2. Uninstall (full)")
    print("3. Reinstall")
    print("4. Disable")
    print("5. Enable")
    while True:
        action = input("Enter action number: ").strip()
        if action in {'1', '2', '3', '4', '5'}:
            return indices, int(action)
        else:
            print("Invalid input. Please enter a number between 1 and 5.")

def run_adb_command(package, action):
    """Executes the appropriate adb command for the selected action and package."""
    if action == 1:
        cmd = f'adb shell pm uninstall -k --user 0 {package}'
    elif action == 2:
        cmd = f'adb shell pm uninstall --user 0 {package}'
    elif action == 3:
        cmd = f'adb shell cmd package install-existing {package}'
    elif action == 4:
        cmd = f'adb shell pm disable-user --user 0 {package}'
    elif action == 5:
        cmd = f'adb shell pm enable {package}'
    else:
        print("[Error] Unknown action.")
        return
    print(f"[Executing] {cmd}")
    try:
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        output = result.stdout.strip() or result.stderr.strip()
        print(output)
        if result.returncode != 0:
            print(f"[Error] adb returned code {result.returncode}.")
            print(f"For troubleshooting or assistance, visit: {SUPPORT_GROUP_URL}")
    except Exception as e:
        print(f"[Exception] Command execution failed: {e}")
        print(f"For troubleshooting or assistance, visit: {SUPPORT_GROUP_URL}")

def main():
    print("\nUniversal Android Bloatware Remover\n"
          "-----------------------------------")
    lists_dir = os.path.join(os.path.dirname(__file__), 'lists')
    brand = get_device_brand()
    file_path = find_brand_file(lists_dir, brand)
    if not file_path:
        print("Proceeding to manual selection of bloatware list...\n")
        file_path = manual_brand_file_selection(lists_dir)
    apps = parse_bloatware_file(file_path)
    if not apps:
        print("[Error] No applications parsed from the list. Please verify the format of your bloatware list file.")
        print(f"For support, visit: {SUPPORT_GROUP_URL}")
        sys.exit(1)
    indices, action = choose_app_and_action(apps)
    for idx in indices:
        app, package = apps[idx]
        print(f"\n[Processing] {app} ({package})")
        run_adb_command(package, action)

if __name__ == '__main__':
    main()
EOF

# Make the debloater.py file executable
chmod +x ~/debloater/debloater.py

print_message "Installation complete! Your directory structure is ready."

# Inform the user how to run the script
print_message "To run your debloater.py script, execute:"
echo "python ~/debloater/debloater.py"
