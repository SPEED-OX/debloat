#!/usr/bin/env python3

"""
Android/OEM Debloat Help
This script provides help and usage information for the Android Debloater tool.

For support, visit: https://t.me/TechGeekZ_chat
"""

import os
from os import get_terminal_size

version = "1.2.0"
telegram = "https://t.me/TechGeekZ_chat"

# Color codes
red = '\033[91m'
cyan = '\033[96m'
white = '\033[0m'
green = '\033[92m'
yellow = '\033[93m'
purple = '\033[95m'
brown = '\033[38;5;208m'

# Terminal width
width = get_terminal_size().columns
l1 = '─' * width
l2 = '-' * width


def display_help():
    os.system("cls" if os.name == "nt" else "clear")
    
    title = 'Android/OEM Debloater - Help'
    l3 = '─' * ((width - len(title)) // 2)
    extra = '─' if (width - len(title)) % 2 != 0 else ''
    
    print(f"\n{l3}{green}{title}{white}{l3}{extra}")
    print(f"\n{green}Version{white}  : {green}{version}{white}")
    print("Author   : TechGeekZ")
    print(f"{cyan}Telegram{white} : {cyan}{telegram}{white}\n")
    print(l2)
    
    print(f"\n{green}DESCRIPTION:{white}")
    print(f"  Android/OEM De-Bloater helps you easily remove unwanted applications (bloatware) from your Android device without requiring {brown}root{white} access or device modifications.\n")
    
    print(f"{green}USAGE:{white}")
    print(f"  {green}debloater{white}         Start the debloater (with ADB auto-connection)")
    print(f"  {green}debloat{white}           Quick debloater (without ADB auto-connect)")
    print(f"  {green}adbservice{white}        Connect to ADB wireless debugging")
    print(f"  {green}debloat --update{white}  Update to latest version from GitHub")
    print(f"  {green}debloat --help{white}    Show this help message\n")
    
    print(f"{green}COMMANDS:{white}")
    print(f"  {green}debloater{white}")
    print("    - Automatically finds and connects to wireless ADB")
    print("    - Detects your device brand")
    print("    - Shows bloatware packages installed on your device")
    print("    - Allows you to uninstall/disable/enable apps\n")
    
    print(f"  {green}adbservice{white}")
    print("    - Manually connect to wireless ADB debugging")
    print("    - Useful when automatic connection fails")
    print("    - Supports multiple device selection\n")
    
    print(f"  {green}debloat --update{white}")
    print("    - Check for updates from GitHub")
    print("    - Download and install newer files")
    print("    - Update bloatware lists and scripts")
    print("    Options:")
    print(f"      {green}--force{white}  : Force update all files")
    print(f"      {green}--check{white}  : Only check for updates (no download)\n")
    
    print(f"{green}REQUIREMENTS:{white}")
    print(f"  1. {brown}Wireless Debugging{white} enabled on your Android device:")
    print(f"     Settings → Developer Options → Wireless Debugging → ON")
    print(f"  2. Device connected to {brown}WiFi{white} or {brown}Hotspot{white}")
    print(f"  3. Both Termux and device on the {brown}same network{white}\n")
    
    print(f"{green}ACTIONS:{white}")
    print(f"  1. {cyan}Uninstall (keep data){white}")
    print("     - Removes app but keeps data for restoration")
    print("     - Can be reinstalled later with data intact\n")
    
    print(f"  2. {cyan}Uninstall (full wipe){white}")
    print("     - Completely removes app and all its data")
    print("     - Cannot restore app data\n")
    
    print(f"  3. {cyan}Reinstall{white}")
    print("     - Restores previously uninstalled apps")
    print("     - Only works if data was kept during uninstall\n")
    
    print(f"  4. {cyan}Disable{white}")
    print("     - Disables app without uninstalling")
    print("     - App won't run or appear in launcher\n")
    
    print(f"  5. {cyan}Enable{white}")
    print("     - Re-enables previously disabled apps")
    print("     - App becomes functional again\n")
    
    print(f"{green}PACKAGE SELECTION:{white}")
    print("  You can select packages in multiple ways:")
    print(f"  • {green}Single{white}  : 5")
    print(f"  • {green}Multiple{white}: 1,3,5")
    print(f"  • {green}Range{white}   : 1-5")
    print(f"  • {green}Mixed{white}   : 1,3-7,10")
    print(f"  • {green}All{white}     : 0 {red}[CAUTION]{white}\n")
    
    print(f"{green}SAFETY:{white}")
    print(f"  • {green}✓{white} Cannot brick your device with this tool")
    print(f"  • {green}✓{white} System boots safe mode after 5 failed boots")
    print(f"  • {green}✓{white} Factory reset will restore all apps")
    print(f"  • {yellow}!{white} Always make backups before debloating")
    print(f"  • {yellow}!{white} Be careful with system-critical apps\n")
    
    print(f"{green}TROUBLESHOOTING:{white}")
    print(f"  {yellow}Problem:{white} ADB connection fails")
    print(f"  {cyan}Solution:{white}")
    print("    - Ensure Wireless Debugging is ON")
    print("    - Check both devices on same WiFi/Hotspot")
    print("    - Try manual pairing with adbservice\n")
    
    print(f"  {yellow}Problem:{white} Brand not supported")
    print(f"  {cyan}Solution:{white}")
    print("    - Common bloatware list will be used")
    print(f"    - Request brand support: {cyan}{telegram}{white}\n")
    
    print(f"  {yellow}Problem:{white} App uninstall failed")
    print(f"  {cyan}Solution:{white}")
    print("    - Some apps are protected by manufacturer")
    print("    - Try disabling instead of uninstalling")
    print("    - Check device-specific restrictions\n")
    
    print(f"{green}IMPORTANT NOTES:{white}")
    print(f"  • {red}DISCLAIMER:{white} Use at your own risk!")
    print("  • Always understand what apps you're removing")
    print("  • Some apps may be required for system stability")
    print("  • Test device functionality after debloating")
    print("  • Keep backups of important data\n")
    
    print(f"{green}MORE INFORMATION:{white}")
    print(f"  • {cyan}GitHub{white}   : https://github.com/SPEED-OX/debloat")
    print(f"  • {cyan}Telegram{white} : {cyan}{telegram}{white}")
    print(f"  • {cyan}Issues{white}   : https://github.com/SPEED-OX/debloat/issues\n")
    
    print(l2)
    print(f"\n{green}~{white} For more help, join our Telegram community!")
    print()


if __name__ == '__main__':
    display_help()
