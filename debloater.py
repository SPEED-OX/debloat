import subprocess
import re
from pathlib import Path

# Install location structure
ROOT_DIR = Path(__file__).parent
LISTS_DIR = ROOT_DIR / "lists"

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)

def parse_txt_file(txt_path):
    raw = txt_path.read_text(encoding='utf-8', errors='ignore')
    packages = re.findall(r'(?:com|cn)(?:\.[a-zA-Z0-9_]+)+', raw)
    return list(set(packages))

def get_all_listed_packages():
    all_packages = set()
    for txt_file in LISTS_DIR.glob("*.txt"):
        pkgs = parse_txt_file(txt_file)
        all_packages.update(pkgs)
    return sorted(all_packages)

def get_installed_packages():
    result = run(['adb', 'shell', 'pm', 'list', 'packages'])
    return set(line.replace("package:", "").strip() for line in result.stdout.splitlines())

def uninstall(pkg, keep_data):
    cmd = ['adb', 'shell', 'pm', 'uninstall']
    if keep_data:
        cmd.append('-k')
    cmd += ['--user', '0', pkg]
    run(cmd)
    print(f"🗑️ Uninstalled ({'kept data' if keep_data else 'full'}): {pkg}")

def restore(pkg):
    result = run(['adb', 'shell', 'cmd', 'package', 'install-existing', pkg])
    if 'installed' in result.stdout.lower():
        print(f"🔁 Restored: {pkg}")
    else:
        print(f"⚠️ Failed to restore: {pkg}")

def disable(pkg):
    result = run(['adb', 'shell', 'pm', 'disable-user', '--user', '0', pkg])
    if 'new state: disabled' in result.stdout.lower():
        print(f"🚫 Disabled: {pkg}")
    else:
        print(f"⚠️ Failed to disable: {pkg}")

def enable(pkg):
    result = run(['adb', 'shell', 'pm', 'enable', pkg])
    if 'new state: enabled' in result.stdout.lower():
        print(f"✅ Enabled: {pkg}")
    else:
        print(f"⚠️ Failed to enable: {pkg}")

def choose_action(pkg):
    print(f"\n📦 {pkg}")
    print(" [1] Uninstall (keep data)")
    print(" [2] Uninstall (full wipe)")
    print(" [3] Restore")
    print(" [4] Disable")
    print(" [5] Enable")
    print(" [Enter] Skip")

    choice = input("→ Your choice: ").strip()
    if choice == '1':
        uninstall(pkg, keep_data=True)
    elif choice == '2':
        uninstall(pkg, keep_data=False)
    elif choice == '3':
        restore(pkg)
    elif choice == '4':
        disable(pkg)
    elif choice == '5':
        enable(pkg)
    else:
        print("⏩ Skipped.")

def main():
    print("📋 Loading bloatware package lists...")
    declared = get_all_listed_packages()
    installed = get_installed_packages()
    matches = [pkg for pkg in declared if pkg in installed]

    if not matches:
        print("✅ No listed bloatware is installed.")
        return

    print(f"\n🔍 Found {len(matches)} matching packages installed on device:\n")
    for i, pkg in enumerate(matches):
        print(f"{i:2d}: {pkg}")

    input("\n🔧 Press Enter to begin managing apps...\n")

    for pkg in matches:
        choose_action(pkg)

if __name__ == '__main__':
    main()
