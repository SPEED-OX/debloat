import subprocess
import re
from pathlib import Path

LIST_DIR = Path(__file__).parent / "lists"

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)

def parse_pkg_file(path):
    text = path.read_text(encoding='utf-8')
    packages = re.findall(r'(?:com|cn)(?:\.[a-zA-Z0-9_]+)+', text)
    return sorted(set(packages))

def get_all_declared_packages():
    all_files = LIST_DIR.glob("*.txt")
    all_packages = set()
    for file in all_files:
        pkgs = parse_pkg_file(file)
        all_packages.update(pkgs)
    return sorted(all_packages)

def get_installed_packages():
    result = run(['adb', 'shell', 'pm', 'list', 'packages'])
    return set(line.replace("package:", "").strip() for line in result.stdout.splitlines())

def uninstall(pkg, keep_data):
    cmd = ['adb', 'shell', 'pm', 'uninstall']
    if keep_data: cmd.append('-k')
    cmd += ['--user', '0', pkg]
    run(cmd)
    print(f"🗑️ Uninstalled ({'kept data' if keep_data else 'full'}): {pkg}")

def restore(pkg):
    result = run(['adb', 'shell', 'cmd', 'package', 'install-existing', pkg])
    print("🔁 Restored: " + pkg if "installed" in result.stdout.lower() else f"⚠️ Failed to restore {pkg}")

def disable(pkg):
    result = run(['adb', 'shell', 'pm', 'disable-user', '--user', '0', pkg])
    print("🚫 Disabled: " + pkg if 'new state: disabled' in result.stdout.lower() else f"⚠️ Failed to disable {pkg}")

def enable(pkg):
    result = run(['adb', 'shell', 'pm', 'enable', pkg])
    print("✅ Enabled: " + pkg if 'new state: enabled' in result.stdout.lower() else f"⚠️ Failed to enable {pkg}")

def choose_action(pkg):
    print(f"\n📦 {pkg}")
    print("1. Uninstall (keep data)")
    print("2. Uninstall (full wipe)")
    print("3. Restore (if possible)")
    print("4. Disable")
    print("5. Enable")
    print("Press Enter to skip")

    choice = input("→ Your choice [1–5]: ").strip()
    if choice == '1': uninstall(pkg, keep_data=True)
    elif choice == '2': uninstall(pkg, keep_data=False)
    elif choice == '3': restore(pkg)
    elif choice == '4': disable(pkg)
    elif choice == '5': enable(pkg)
    else: print("⏩ Skipped.")

def main():
    print("🔌 Checking connected Android device...\n")
    declared_pkgs = get_all_declared_packages()
    installed_pkgs = get_installed_packages()

    matches = [pkg for pkg in declared_pkgs if pkg in installed_pkgs]

    if not matches:
        print("✅ No bloatware apps from known lists are installed.")
        return

    print(f"🤖 Found {len(matches)} installed matches:\n")
    for i, pkg in enumerate(matches):
        print(f"{i}: {pkg}")

    input("\n🚀 Press Enter to start managing apps...\n")
    for pkg in matches:
        choose_action(pkg)

if __name__ == '__main__':
    main()
