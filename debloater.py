import os
import re
import subprocess
import sys

TELEGRAM_GROUP = "https://t.me/TechGeekZ_chat"  # <-- put your actual group link here

def print_help_message(error_msg=None):
    print("\n" + "="*60)
    print("⚠️  An issue occurred during device brand detection.")
    if error_msg:
        print(f"Error details: {error_msg}")
    print("For support, please join our Telegram group:")
    print(TELEGRAM_GROUP)
    print("="*60 + "\n")

def get_device_brand():
    try:
        result = subprocess.run(
            ['adb', 'shell', 'getprop', 'ro.product.brand'],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            print_help_message(result.stderr.strip())
            return None
        brand = result.stdout.strip().lower()
        if not brand:
            print_help_message("No output received from adb shell getprop.")
            return None
        print(f"✅ Detected device brand: {brand}")
        return brand
    except Exception as e:
        print_help_message(str(e))
        return None

def find_brand_file(lists_dir, brand):
    files = [f for f in os.listdir(lists_dir) if f.endswith('.txt')]
    if not files:
        print("No bloatware lists found in the lists/ directory.")
        sys.exit(1)
    if not brand:
        return None
    # Try exact or partial match
    for f in files:
        if f.startswith(brand):
            print(f"📝 Using list: {f} for brand: {brand}")
            return os.path.join(lists_dir, f)
    print(f"\n⚠️  No list found for detected brand: {brand}.")
    print("This brand is currently unsupported or being updated.")
    print("Request support or report your device in our Telegram group:")
    print(TELEGRAM_GROUP)
    print()
    return None

def manual_brand_file_selection(lists_dir):
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
                print("Invalid selection. Try again.")
        except Exception:
            print("Invalid input. Please enter a number.")

def parse_bloatware_file(filepath):
    apps = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            # Format 1: "AppName pm uninstall ... package.name"
            match = re.match(r'(.+?)(?:\s+pm\s+\w+[\w\s\-–—]+)?\s+([a-zA-Z0-9_.]+)$', line)
            if match:
                app, package = match.group(1), match.group(2)
                apps.append( (app.strip(), package.strip()) )
                continue
            # Format 2: "AppName ➡️ package.name"
            arrow_match = re.match(r'(.+?)\s*[➡️]\s*([a-zA-Z0-9_.]+)$', line)
            if arrow_match:
                app, package = arrow_match.group(1), arrow_match.group(2)
                apps.append( (app.strip(), package.strip()) )
                continue
            # Format 3: "package.name - description" or "package.name"
            package_only = re.match(r'^([a-zA-Z0-9_.]+)(?:\s*-\s*.+)?$', line)
            if package_only:
                package = package_only.group(1)
                app = package
                apps.append( (app.strip(), package.strip()) )
    return apps

def choose_app_and_action(apps):
    print("\nAvailable apps:")
    for idx, (app, package) in enumerate(apps):
        print(f"{idx+1}. {app} ({package})")
    print("0. [Batch] Select ALL apps")
    while True:
        selected = input("Enter app number (or 0 for all): ").strip()
        if selected == '0':
            indices = list(range(len(apps)))
            break
        try:
            idx = int(selected) - 1
            if 0 <= idx < len(apps):
                indices = [idx]
                break
            else:
                print("Invalid selection. Try again.")
        except Exception:
            print("Invalid input. Please enter a number.")
    print("\nChoose action:")
    print("1. Uninstall (keep data)")
    print("2. Uninstall (full)")
    print("3. Reinstall")
    print("4. Disable")
    print("5. Enable")
    while True:
        action = input("Enter action number: ").strip()
        if action in {'1','2','3','4','5'}:
            return indices, int(action)
        else:
            print("Invalid input. Please enter a number from 1 to 5.")

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
        print("Unknown action")
        return
    print(f"Running: {cmd}")
    try:
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        print(result.stdout.strip() or result.stderr.strip())
    except Exception as e:
        print(f"Error executing command: {e}")
        print("If you need help, please join our Telegram group:")
        print(TELEGRAM_GROUP)

def main():
    print("=== Universal Android Bloatware Remover ===\n")
    lists_dir = os.path.join(os.path.dirname(__file__), 'lists')
    brand = get_device_brand()
    file_path = find_brand_file(lists_dir, brand)
    if not file_path:
        print("Proceeding to manual selection...\n")
        file_path = manual_brand_file_selection(lists_dir)
    apps = parse_bloatware_file(file_path)
    if not apps:
        print("No apps parsed from the list. Please check your bloatware list file format.")
        print("If you need help, join our Telegram group:")
        print(TELEGRAM_GROUP)
        sys.exit(1)
    indices, action = choose_app_and_action(apps)
    for idx in indices:
        app, package = apps[idx]
        print(f"\nProcessing: {app} ({package})")
        run_adb_command(package, action)

if __name__ == '__main__':
    main()
