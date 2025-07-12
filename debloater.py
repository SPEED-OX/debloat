#!/usr/bin/env python3

"""
Android/OEM Debloat Uninstaller
version = 1.1
This script is the simpliest option to unnistall unwantes apps without any sweat using corresponding bloatware list to assist the user in uninstalling, disabling, enabling, or reinstalling apps.

For support, visit: https://t.me/TechGeekZ_chat
"""

import os
import re
import subprocess
import sys

BRAND_COLORS = {
    'realme': '\033[93m',       # Yellow
    'xiaomi': '\033[38;5;208m', # Orange
    'poco': '\033[38;5;208m',   # Orange (same as Xiaomi)
    'mi': '\033[38;5;208m',     # Orange (same as Xiaomi)
    'oneplus': '\033[91m',      # Red
    'vivo': '\033[94m',         # Blue
    'oppo': '\033[92m',         # Green
    'samsung': '\033[96m',      # Cyan
    'huawei': '\033[95m',       # Magenta
    'honor': '\033[97m',        # White
    'motorola': '\033[90m',     # Dark Gray
    'nokia': '\033[34m',        # Blue
    'lg': '\033[35m',           # Purple
    'sony': '\033[33m',         # Yellow
    'htc': '\033[36m',          # Cyan
    'asus': '\033[31m',         # Red
    'lenovo': '\033[32m',       # Green
    'meizu': '\033[37m',        # Light Gray
    'tcl': '\033[38;5;166m',    # Orange
    'alcatel': '\033[38;5;21m', # Blue
    'blackberry': '\033[30m',   # Black
    'google': '\033[38;5;214m', # Orange
    'nothing': '\033[97m',      # White
    'fairphone': '\033[92m',    # Green
}

# UI Colors
RESET_COLOR = '\033[0m'
GREEN_COLOR = '\033[92m'
RED_COLOR = '\033[91m'
LIGHT_BLUE_COLOR = '\033[38;5;117m'
TELEGRAM_COLOR = '\033[38;2;37;150;190m'
CYAN_COLOR = '\033[96m'

BRAND_MAPPING = {
    'poco': 'xiaomi',
    'mi': 'xiaomi',
    'redmi': 'xiaomi',
    'black_shark': 'xiaomi',    # Xiaomi's sub-brand
    'iqoo': 'vivo',             # iQOO is Vivo's sub-brand
    'realme': 'oppo',           # Realme was originally Oppo's sub-brand
    'oneplus': 'oppo',          # OnePlus is now under Oppo
    'honor': 'huawei',          # Honor was Huawei's sub-brand
    'redmagic': 'nubia',
}

SUPPORT_GROUP_URL = "https://t.me/TechGeekZ_chat"

def check_adb_connection():
    """ Checks if ADB is available and if any device is connected. Returns True if connected, False otherwise. """
    # Check if adb is available
    try:
        result = subprocess.run(['adb', 'version'], capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print(f"\n- Checking ADB Connection: {RED_COLOR}DISCONNECTED{RESET_COLOR}")
            print(f"{RED_COLOR}connect to adb first{RESET_COLOR}")
            print("[Error] ADB is not installed or not in PATH.")
            return False
    except Exception as e:
        print(f"\n- Checking ADB Connection: {RED_COLOR}DISCONNECTED{RESET_COLOR}")
        print(f"{RED_COLOR}connect to adb first{RESET_COLOR}")
        print(f"[Error] ADB is not available: {e}")
        return False

    # Check device connection
    try:
        result = subprocess.run(['adb', 'devices'], capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print(f"\n- Checking ADB Connection: {RED_COLOR}DISCONNECTED{RESET_COLOR}")
            print(f"{RED_COLOR}connect to adb first{RESET_COLOR}")
            print("[Error] Failed to check device connection.")
            return False

        devices = result.stdout.strip().split('\n')[1:]  # Skip header line
        connected_devices = [line for line in devices if line.strip() and 'device' in line]

        if not connected_devices:
            print(f"\n- Checking ADB Connection: {RED_COLOR}DISCONNECTED{RESET_COLOR}")
            print(f"{RED_COLOR}- connect to adb first! {RESET_COLOR}")
            print("[Status] No devices connected via ADB, Wireless Debugging")
            print("\nPlease ensure:")
            print("- wireless debugging is enabled on your device")
            print("- Device is paired/connected via wireless debugging")
            #print("- You have authorized the ADB connection on your device")
            return False

        print(f"\n~ Checking ADB Connection: {GREEN_COLOR}CONNECTED{RESET_COLOR}")
        return True

    except Exception as e:
        print(f"\n~ Checking ADB Connection: {RED_COLOR}CONNECTED{RESET_COLOR}")
        print(f"{RED_COLOR}connect to adb first{RESET_COLOR}")
        print(f"[Error] Failed to check device connection: {e}")
        return False

def get_device_brand():
    #Attempts to detect the Android device brand using adb. Returns the brand as a lowercase string, or None if detection fails.
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

        return brand

    except Exception as e:
        print(f"[Exception] Brand detection failed: {e}")
        return None

def print_colored_brand(brand):
    """ Prints the device brand in its corresponding brand color. """
    print()
    if brand in BRAND_COLORS:
        color = BRAND_COLORS[brand]
        print(f"\n{GREEN_COLOR}~ Device Brand:{RESET_COLOR} {color}{brand.upper()}{RESET_COLOR}")
    else:
        print(f"\n{GREEN_COLOR}~ Device Brand:{RESET_COLOR} {brand.upper()}")
    print()

def get_mapped_brand(brand):
    """ Returns the mapped brand for bloatware list lookup. """
    return BRAND_MAPPING.get(brand, brand)

def check_brand_list_availability(lists_dir, brand):
    """ Checks if a bloatware list file exists for the given brand. Uses brand mapping to find the correct list file. Returns the full path if found, otherwise None. """
    if not brand:
        return None

    # Get the mapped brand for file lookup
    mapped_brand = get_mapped_brand(brand)
    brand_file = f"{mapped_brand}.txt"
    file_path = os.path.join(lists_dir, brand_file)

    if os.path.exists(file_path):
        return file_path
    else:
        return None

def get_installed_packages():
    """ Gets all installed packages on the connected device. Returns a set of package names. """
    try:
        result = subprocess.run(
            ['adb', 'shell', 'pm', 'list', 'packages'],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"[Error] Failed to get installed packages: {result.stderr.strip()}")
            return set()

        packages = set()
        for line in result.stdout.strip().split('\n'):
            if line.startswith('package:'):
                package_name = line.replace('package:', '').strip()
                packages.add(package_name)

        return packages

    except Exception as e:
        print(f"[Exception] Failed to get installed packages: {e}")
        return set()

def parse_bloatware_file(filepath):
    """ Parses the specified bloatware list file, extracting tuples of (package_name, app_name). Expected format: "com.package.name  ( App Name )" or "com.package.name" """
    apps = []

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue

                # Format: "com.package.name  ( App Name )"
                match = re.match(r'^([a-zA-Z0-9_.]+)\s*\(\s*(.+?)\s*\)$', line)
                if match:
                    package, app_name = match.group(1).strip(), match.group(2).strip()
                    apps.append((package, app_name))
                    continue

                # Format: "com.package.name"
                package_match = re.match(r'^([a-zA-Z0-9_.]+)$', line)
                if package_match:
                    package = package_match.group(1).strip()
                    apps.append((package, package))  # Use package name as display name
                    continue

                print(f"[Warning] Skipping malformed line {line_num}: {line}")

        return apps

    except Exception as e:
        print(f"[Error] Failed to parse bloatware file: {e}")
        return []

def display_matching_packages(apps, installed_packages):
    """ Displays packages from the bloatware list that are actually installed on the device. """
    matching_apps = []

    for package, app_name in apps:
        if package in installed_packages:
            matching_apps.append((package, app_name))

    if not matching_apps:
        print("[Info] No bloatware packages from the list are currently installed on this device.")
        return []

    print(f"\n~ Found {GREEN_COLOR}{len(matching_apps)}{RESET_COLOR} bloatware packages installed")
    print(f"{GREEN_COLOR}{'─' * 50}{RESET_COLOR}")

    for idx, (package, app_name) in enumerate(matching_apps, 1):
        print(f"{GREEN_COLOR}{idx:2d}. {RESET_COLOR} {package} ({app_name})")

    print(f"{GREEN_COLOR}{'─' * 50}{RESET_COLOR}")
    print(f"{GREEN_COLOR}0. {RESET_COLOR} [Batch] To Select ALL applications {RED_COLOR}[CAUTION] {RESET_COLOR}")
    print("─" * 50)

    return matching_apps

def parse_selection(selection_str, max_count):
    """ Parses user selection string and returns list of valid indices. """
    indices = set()
    parts = [part.strip() for part in selection_str.split(',')]

    for part in parts:
        if '-' in part:  # Handle range (e.g., "1-5")
            try:
                start, end = part.split('-', 1)
                start_idx = int(start.strip()) - 1  # Convert to zero-based
                end_idx = int(end.strip()) - 1      # Convert to zero-based

                if start_idx < 0 or end_idx >= max_count or start_idx > end_idx:
                    print(f"{RED_COLOR}Invalid range: {part} (valid range: 1-{max_count}){RESET_COLOR}")
                    return []

                indices.update(range(start_idx, end_idx + 1))
            except ValueError:
                print(f"{RED_COLOR}Invalid range format: {part}{RESET_COLOR}")
                return []
        else:  # Handle single number
            try:
                idx = int(part.strip()) - 1  # Convert to zero-based
                if idx < 0 or idx >= max_count:
                    print(f"{RED_COLOR}Invalid package number: {int(part)} (valid range: 1-{max_count}){RESET_COLOR}")
                    return []
                indices.add(idx)
            except ValueError:
                print(f"{RED_COLOR}Invalid number: {part}{RESET_COLOR}")
                return []

    return sorted(list(indices))

def choose_app_and_action(apps):
    """ Presents the list of apps and prompts the user to select one or all, then choose the desired action. Returns a tuple (indices, action). """
    while True:
        selected = input(f"\n{GREEN_COLOR}~{RESET_COLOR} Select Package(s) [{GREEN_COLOR}1{RESET_COLOR}~{GREEN_COLOR}{len(apps)}{RESET_COLOR}]: ").strip()
        if selected == '0':
            indices = list(range(len(apps)))
            break

        try:
            indices = parse_selection(selected, len(apps))
            if indices:
                break
            else:
                print(f"{RED_COLOR}Invalid selection. Please try again.{RESET_COLOR}")
        except Exception:
            print(f"{RED_COLOR}Invalid input format. Please use formats like: 5; 1-5; 1,3,5; or 1,3-7,10{RESET_COLOR}")

    print(f"\n{GREEN_COLOR}~{RESET_COLOR} Selected : {GREEN_COLOR}{len(indices)}{RESET_COLOR}\n")
    for idx in indices:
        package, app_name = apps[idx]
        print(f"{GREEN_COLOR}{idx+1:2d}. {RESET_COLOR} {package} ({app_name})")

    # Confirm selection
    confirm = input(f"\n{GREEN_COLOR}~{RESET_COLOR} Confirm Selection? ({GREEN_COLOR}y{RESET_COLOR}/{RED_COLOR}n{RESET_COLOR}): ").strip().lower()
    if confirm not in ['y', 'yes', '']:
        print("Selection cancelled. Please try again.")
        return choose_app_and_action(apps)  # Recursive call to restart selection

    print(f"\n{GREEN_COLOR}~{RESET_COLOR} Choose Action [{GREEN_COLOR}1{RESET_COLOR}~{GREEN_COLOR}5{RESET_COLOR}]")
    print(f"{GREEN_COLOR}1. {RESET_COLOR} Uninstall ({GREEN_COLOR}keep data for restore{RESET_COLOR})")
    print(f"{GREEN_COLOR}2. {RESET_COLOR} Uninstall ({RED_COLOR}full wipe{RESET_COLOR})")
    print(f"{GREEN_COLOR}3. {RESET_COLOR} Reinstall")
    print(f"{GREEN_COLOR}4. {RESET_COLOR} Disable")
    print(f"{GREEN_COLOR}5. {RESET_COLOR} Enable")

    while True:
        action = input(f"\n{GREEN_COLOR}~{RESET_COLOR} Choice [{GREEN_COLOR}1{RESET_COLOR}~{GREEN_COLOR}5{RESET_COLOR}]: ").strip()
        if action in {'1', '2', '3', '4', '5'}:
            return indices, int(action)
        else:
            print("Invalid input. Please enter a number between 1 and 5.")

def get_action_text(action):
    actions = {
        1: "uninstalling",
        2: "complete uninstalling",
        3: "reinstalling",
        4: "disabling",
        5: "enabling"
    }
    return actions.get(action, "processing")

def run_adb_command(package, action):
    """ Executes the appropriate adb command for the selected action and package. Returns True if successful, False otherwise. """
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
        return False

    try:
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        output = result.stdout.strip() or result.stderr.strip()

        if result.returncode == 0 and ("Success" in output or "Installed" in output or "enabled" in output or "disabled" in output):
            print(f"{GREEN_COLOR}SUCCESS !!{RESET_COLOR}")
            return True
        else:
            print(f"{RED_COLOR}FAILED !!{RESET_COLOR} {output}")
            return False

    except Exception as e:
        print(f"{RED_COLOR}FAILED !!{RESET_COLOR} Command execution failed: {e}")
        return False

def main():
    print(f"\n{'─' * 14}{GREEN_COLOR}Android/OEM Debloater{RESET_COLOR}{'─' * 14}")
    print(f"\n{GREEN_COLOR}Version{RESET_COLOR}: {GREEN_COLOR}1.0{RESET_COLOR}")
    print("Author: TechGeekZ")
    print(f"{TELEGRAM_COLOR}Telegram{RESET_COLOR}: {TELEGRAM_COLOR}https://t.me/TechGeekZ_chat{RESET_COLOR}")
    print(f"\n{'─' * 50}")

    # Step 1: Check ADB connection
    if not check_adb_connection():
        sys.exit(1)

    # Step 2: Get and display device brand
    brand = get_device_brand()
    if not brand:
        print("[Error] Could not detect device brand. Exiting.")
        sys.exit(1)

    print_colored_brand(brand)

    # Step 3: Check if brand list is available
    lists_dir = os.path.join(os.path.dirname(__file__), 'lists')

    if not os.path.exists(lists_dir):
        print(f"[Error] Lists directory not found: {lists_dir}")
        sys.exit(1)

    # Check for brand-specific list
    brand_file_path = check_brand_list_availability(lists_dir, brand)

    # Check for common list
    common_file_path = os.path.join(lists_dir, 'common.txt')
    common_exists = os.path.exists(common_file_path)

    # If no brand-specific list exists, show error message
    if not brand_file_path:
        if common_exists:
            print(f"{RED_COLOR}[ERROR]{RESET_COLOR} Listing only common bloatwares{RED_COLOR}! {RESET_COLOR}")
            brand_color = BRAND_COLORS.get(brand, '')
            print(f"{RED_COLOR}[ERROR]{RESET_COLOR} This Brand {brand_color}{brand.upper()}{RESET_COLOR} is not yet supported{RED_COLOR}! {RESET_COLOR}")
            print(f"\nFor support or To request this brand,")
            print(f"visit: {TELEGRAM_COLOR}{SUPPORT_GROUP_URL}{RESET_COLOR}")
        else:
            print(f"[Error] This device brand ({brand.upper()}) is not yet supported.")
            print(f"For support or to request this brand, visit: {SUPPORT_GROUP_URL}")
            sys.exit(1)

    # Step 4: Get installed packages
    installed_packages = get_installed_packages()

    if not installed_packages:
        print("[Error] Could not retrieve installed packages from device.")
        sys.exit(1)

    # Step 5: Parse bloatware lists
    all_apps = []

    # Load brand-specific list if available
    if brand_file_path:
        brand_apps = parse_bloatware_file(brand_file_path)
        all_apps.extend(brand_apps)

    # Always load common list if available
    if common_exists:
        common_apps = parse_bloatware_file(common_file_path)
        all_apps.extend(common_apps)

    if not all_apps:
        print("[Error] No applications parsed from the list. Please verify the format of your bloatware list file.")
        print(f"For support, visit: {SUPPORT_GROUP_URL}")
        sys.exit(1)

    # Step 6: Display matching packages
    matching_apps = display_matching_packages(all_apps, installed_packages)

    if not matching_apps:
        print("\nYour device appears to be clean of the known bloatware packages!")
        sys.exit(0)

    # Step 7: Let user choose action
    indices, action = choose_app_and_action(matching_apps)

    # Step 8: Execute actions with error handling
    action_text = get_action_text(action)
    successful_count = 0
    failed_count = 0

    for idx in indices:
        package, app_name = matching_apps[idx]
        print(f"\n[{action_text}] {app_name} ({package})")
        
        if run_adb_command(package, action):
            successful_count += 1
        else:
            failed_count += 1

    # Summary
    print(f"\n{'─' * 50}")
    print(f"{' ' * 18}~ {CYAN_COLOR}CONCLUSION{RESET_COLOR} ~")
    print(f"{'─' * 50}")
    print(f"\n{GREEN_COLOR}SUCCESS:{RESET_COLOR} {successful_count}")
    if failed_count > 0:
        print(f"{RED_COLOR}FAILED:{RESET_COLOR} {failed_count}")
        print(f"\nFor troubleshooting failed operations, visit: {TELEGRAM_COLOR}{SUPPORT_GROUP_URL}{RESET_COLOR}")

if __name__ == '__main__':
    main()
