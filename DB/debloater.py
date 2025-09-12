#!/usr/bin/env python3

"""
Android/OEM Debloat Uninstaller
This script is the simplest option to uninstall unwanted apps without any sweat using corresponding bloatware list to assist the user in uninstalling, disabling, enabling, or reinstalling apps.

For support, visit: https://t.me/TechGeekZ_chat
"""

import os, re, subprocess, sys
from os import get_terminal_size

version = "1.2.0"
telegram = "https://t.me/TechGeekZ_chat"

BRAND_FAMILIES = {
    'oppo': ['oppo', 'realme', 'oneplus'],
    'vivo': ['vivo', 'iqoo'],
    'nubia': ['nubia', 'redmagic'],
    'huawei': ['huawei', 'honor'],
    'xiaomi': ['xiaomi', 'redmi', 'poco', 'mi', 'black_shark'],
}


BRAND_MAPPING = {}
for main_brand, sub_brands in BRAND_FAMILIES.items():
    for sub_brand in sub_brands:
        BRAND_MAPPING[sub_brand] = main_brand


BRAND_COLORS = {
    'mi'        : '\033[38;5;208m',  # Orange (same as Xiaomi)
    'lg'        : '\033[35m',        # Purple
    'htc'       : '\033[36m',        # Cyan
    'tcl'       : '\033[38;5;166m',  # Orange
    'oppo'      : '\033[92m',        # Green
    'poco'      : '\033[38;5;208m',  # Orange (same as Xiaomi)
    'sony'      : '\033[33m',        # Yellow
    'vivo'      : '\033[94m',        # Blue
    'asus'      : '\033[31m',        # Red
    'realme'    : '\033[93m',        # Yellow
    'google'    : '\033[38;5;214m',  # Orange
    'honor'     : '\033[97m',        # White
    'huawei'    : '\033[95m',        # Magenta
    'lenovo'    : '\033[32m',        # Green
    'meizu'     : '\033[37m',        # Light Gray
    'nokia'     : '\033[34m',        # Blue
    'nothing'   : '\033[97m',        # White
    'oneplus'   : '\033[91m',        # Red
    'samsung'   : '\033[96m',        # Cyan
    'xiaomi'    : '\033[38;5;208m',  # Orange
    'alcatel'   : '\033[38;5;21m',   # Blue
    'fairphone' : '\033[92m',        # Green
    'motorola'  : '\033[90m',        # Dark Gray
    'blackberry': '\033[30m',        # Black
    'nubia'     : '\033[95m',        # Magenta
    'redmagic'  : '\033[95m',        # Magenta
}


red   = '\033[91m'
cyan  = '\033[96m'
white = '\033[0m'
green = '\033[92m'
brown = '\033[38;5;208m'


width = get_terminal_size().columns
l1 = '─' * width
l2 = '-' * width

def check_adb_connection():
    try:
        result = subprocess.run(['adb', 'version'], capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print(f"\n- Checking ADB Connection: {red}DISCONNECTED{white}")
            print(f"{red}connect to adb first{white}")
            print("[Error] ADB is not installed or not in PATH.")
            return False
    except Exception as e:
        print(f"\n- Checking ADB Connection: {red}DISCONNECTED{white}")
        print(f"{red}connect to adb first{white}")
        print(f"[Error] ADB is not available: {e}")
        return False
    try:
        result = subprocess.run(['adb', 'devices'], capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print(f"\n- Checking ADB Connection: {red}DISCONNECTED{white}")
            print(f"{red}- connect to adb first! {white}")
            print("\nPlease ensure:")
            print(f"- {brown}Wireless Debugging{white} is enabled on your device")
            print(f"- Device is paired/connected via {brown}wireless debugging{white}")
            print(f"\n\n{green}~{white} Use command [ {green}adb{white} ] to connect to {brown}Wireless ADB Debugging{white}\n")
            return False

        devices = result.stdout.strip().split('\n')[1:]
        connected_devices = [line for line in devices if line.strip() and 'device' in line]

        if not connected_devices:
            print(f"\n- Checking ADB Connection: {red}DISCONNECTED{white}")
            print(f"{red}- connect to adb first! {white}")
            print("\nPlease ensure:")
            print(f"- {brown}Wireless Debugging{white} is enabled on your device")
            print(f"- Device is paired/connected via {brown}wireless debugging{white}")
            print(f"\n\n{green}~{white} Use command [ {green}adb{white} ] to connect to {brown}Wireless ADB Debugging{white}\n")
            return False

        print(f"\n~ Checking ADB Connection: {green}CONNECTED{white}")
        return True

    except Exception as e:
        print(f"\n~ Checking ADB Connection: {red}CONNECTED{white}")
        print(f"{red}connect to adb first{white}")
        print(f"[Error] Failed to check device connection: {e}")
        return False

def get_device_brand():
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
    print()
    if brand in BRAND_COLORS:
        color = BRAND_COLORS[brand]
        print(f"\n~{green} Device Brand{white} : {color}{brand.upper()}{white}")
    else:
        print(f"\n~{green} Device Brand{white} : {brand.upper()}")
    print()

def get_mapped_brand(brand):
    return BRAND_MAPPING.get(brand, brand)

def check_brand_list_availability(lists_dir, brand):
    if not brand:
        return None

    mapped_brand = get_mapped_brand(brand)
    brand_file = f"{mapped_brand}.txt"
    file_path = os.path.join(lists_dir, brand_file)

    if os.path.exists(file_path):
        return file_path
    else:
        return None

def get_installed_packages():
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
    apps = []

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue

                match = re.match(r'^([a-zA-Z0-9_.]+)\s*\(\s*(.+?)\s*\)$', line)
                if match:
                    package, app_name = match.group(1).strip(), match.group(2).strip()
                    apps.append((package, app_name))
                    continue

                package_match = re.match(r'^([a-zA-Z0-9_.]+)$', line)
                if package_match:
                    package = package_match.group(1).strip()
                    apps.append((package, package))
                    continue

                print(f"[Warning] Skipping malformed line {line_num}: {line}")

        return apps

    except Exception as e:
        print(f"[Error] Failed to parse bloatware file: {e}")
        return []

def display_matching_packages(apps, installed_packages):
    matching_apps = []

    for package, app_name in apps:
        if package in installed_packages:
            matching_apps.append((package, app_name))

    if not matching_apps:
        print("[Info] No bloatware packages from the known list are currently installed on this device.")
        return []

    print(l2)
    print(f"\n\n~ Found {green}{len(matching_apps)}{white} bloatware packages installed")
    print(green + l1 + white)

    for idx, (package, app_name) in enumerate(matching_apps, 1):
        print(f"{green}{idx:2d}. {white} {package} ({app_name})")

    print(green + l1 + white)
    print(f"{green}0. {white} [Batch] To Select ALL applications {red}[CAUTION] {white}")
    print(l1)

    return matching_apps

def parse_selection(selection_str, max_count):
    indices = set()
    parts = [part.strip() for part in selection_str.split(',')]

    for part in parts:
        if '-' in part:
            try:
                start, end = part.split('-', 1)
                start_idx = int(start.strip()) - 1
                end_idx = int(end.strip()) - 1

                if start_idx < 0 or end_idx >= max_count or start_idx > end_idx:
                    print(f"{red}Invalid range: {part} (valid range: 1-{max_count}){white}")
                    return []

                indices.update(range(start_idx, end_idx + 1))
            except ValueError:
                print(f"{red}Invalid range format: {part}{white}")
                return []
        else:
            try:
                idx = int(part.strip()) - 1
                if idx < 0 or idx >= max_count:
                    print(f"{red}Invalid package number: {int(part)} (valid range: 1-{max_count}){white}")
                    return []
                indices.add(idx)
            except ValueError:
                print(f"{red}Invalid number: {part}{white}")
                return []

    return sorted(list(indices))

def choose_app_and_action(apps):
    while True:
        selected = input(f"\n- Format Example {green}[{white} 1,2,3-7,10 {green}]\n\n~{white} Select Package(s) [{green}1{white}~{green}{len(apps)}{white}]: ").strip()
        if selected == '0':
            indices = list(range(len(apps)))
            break

        try:
            indices = parse_selection(selected, len(apps))
            if indices:
                break
            else:
                print(f"{red}Invalid selection. Please try again.{white}")
        except Exception:
            print(f"{red}Invalid input format. Please use formats like: 5; 1-5; 1,3,5; or 1,3-7,10{white}")

    print(f"\n\n{l2}{green}~{white} Selected : {green}{len(indices)}{white}\n")
    for idx in indices:
        package, app_name = apps[idx]
        print(f"{green}{idx+1:2d}. {white} {package} ({app_name})")
    print(f"\n{l2}")

    confirm = input(f"\n{green}~{white} Confirm Selection? ({green}y{white}/{red}n{white}): ").strip().lower()
    if confirm not in ['y', 'yes']:
        print("Selection cancelled. Please try again.")
        return choose_app_and_action(apps)

    print(f"\n{green}~{white} Choose Action [{green}1{white}~{green}5{white}]")
    print(f"{green}1. {white} Uninstall ({green}keep data for restore{white})")
    print(f"{green}2. {white} Uninstall ({red}full wipe{white})")
    print(f"{green}3. {white} Reinstall")
    print(f"{green}4. {white} Disable")
    print(f"{green}5. {white} Enable")

    while True:
        action = input(f"\n{green}~{white} Choice [{green}1{white}~{green}5{white}]: ").strip()
        if action in {'1', '2', '3', '4', '5'}:
            return indices, int(action)
        else:
            print("Invalid input. Please enter a number between 1 and 5.")

def get_action_text(action):
    actions = {
        1: f"{cyan}Uninstalling{white}",
        2: f"{cyan}Complete Uninstalling{white}",
        3: f"{cyan}Reinstalling{white}",
        4: f"{cyan}Disabling{white}",
        5: f"{cyan}Enabling{white}"
    }
    return actions.get(action, "processing")

def run_adb_command(package, action):
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
            print(f"\n{green}SUCCESS !!{white}")
            return True
        else:
            print(f"{red}FAILED !!{white} {output}")
            return False

    except Exception as e:
        print(f"{red}FAILED !!{white} Command execution failed: {e}")
        return False

def main():
    os.system("cls" if os.name == "nt" else "clear")
    
    title = 'Android/OEM Debloater'
    l3 = '─' * ((width - len(title)) // 2)
    if (width - len(title)) % 2 != 0:
        extra = '─'
    else:
        extra = ''
    print(f"\n{l3}{green}{title}{white}{l3}{extra}")
    print(f"\n{green}Version{white}  : {green}{version}{white}")
    print("Author   : TechGeekZ")
    print(f"{cyan}Telegram{white} : {cyan}{telegram}{white}\n")
    print(l2)

    if not check_adb_connection():
        sys.exit(1)

    brand = get_device_brand()
    if not brand:
        print("[Error] Could not detect device brand. Exiting.")
        sys.exit(1)

    print_colored_brand(brand)

    lists_dir = os.path.join(os.path.dirname(__file__), 'lists')

    if not os.path.exists(lists_dir):
        print(f"[Error] Lists directory not found: {lists_dir}")
        sys.exit(1)

    brand_file_path = check_brand_list_availability(lists_dir, brand)

    common_file_path = os.path.join(lists_dir, 'common.txt')
    common_exists = os.path.exists(common_file_path)

    if not brand_file_path:
        if common_exists:
            print(f"{red}[ERROR]{white} Listing only common bloatwares{red}! {white}")
            brand_color = BRAND_COLORS.get(brand, '')
            print(f"{red}[ERROR]{white} This Brand {brand_color}{brand.upper()}{white} is not yet supported{red}! {white}")
            print(f"\nFor support or To request this brand,")
            print(f"visit: {cyan}{telegram}{white}")
        else:
            print(f"[Error] This device brand ({brand.upper()}) is not yet supported.")
            print(f"For support or to request this brand, visit: {telegram}")
            sys.exit(1)

    installed_packages = get_installed_packages()

    if not installed_packages:
        print("[Error] Could not retrieve installed packages from device.")
        sys.exit(1)

    all_apps = []

    if brand_file_path:
        brand_apps = parse_bloatware_file(brand_file_path)
        all_apps.extend(brand_apps)

    if common_exists:
        common_apps = parse_bloatware_file(common_file_path)
        all_apps.extend(common_apps)

    if not all_apps:
        print("[Error] No applications parsed from the list. Please verify the format of your bloatware list file.")
        print(f"For support, visit: {telegram}")
        sys.exit(1)

    matching_apps = display_matching_packages(all_apps, installed_packages)

    if not matching_apps:
        print("\nYour device appears to be clean of the known bloatware packages!")
        sys.exit(0)

    indices, action = choose_app_and_action(matching_apps)

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

    l4 = ' ' * ((width - 14) // 2)
    print(l1)
    print(f"{l4}~ {cyan}CONCLUSION{white} ~")
    print(l1)
    print(f"\n\n{green}SUCCESS:{white} {successful_count}\n\n")
    if failed_count > 0:
        print(f"{red}FAILED:{white} {failed_count}")
        print(f"\nFor troubleshooting failed operations, visit: {cyan}{telegram}{white}")

if __name__ == '__main__':
    main()
