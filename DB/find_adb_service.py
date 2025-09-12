"""
Wireless ADB Connect
Version = 1.0
Made by - Offici5l
Modified by - TechGeekZ

For support, visit: https://t.me/TechGeekZ_chat
"""

import time
import socket
import sys
import subprocess
from zeroconf import ServiceBrowser, Zeroconf
from os import get_terminal_size

version = "1.0"
telegram = "https://t.me/TechGeekZ_chat"

red  = '\033[91m'
cyan = '\033[96m'
white = '\033[97m'
green = '\033[92m'
purple = '\033[95m'
orange = '\033[38;5;208m'

title = ' Wireless ADB '
width = get_terminal_size().columns

l1 = '─' * ((width - len(title)) // 2)
l2 = '─' * width
extra = '─'
if (width - len(title)) % 2 != 0:
    extra = '─'
else:
    extra = ''
        
print(l1 + purple + title + white + l1 + extra)
print(f"""
{green}Version{white}  : {green}{version}{white}
Author   : Offici5l/TechGeekZ
{cyan}Telegram{white} : {cyan}{telegram}{white}
""")
print(l2)

time.sleep(1)

class ADBListener:
    def __init__(self):
        self.services = []

    def remove_service(self, zeroconf, type_, name):
        pass

    def add_service(self, zeroconf, type_, name):
        info = zeroconf.get_service_info(type_, name)
        if info:
            self.services.append(info)
        global found
        found = True

    def update_service(self, zeroconf, type_, name):
        pass

def find_adb_service(timeout=10):
    zeroconf = Zeroconf()
    listener = ADBListener()
    browser = ServiceBrowser(zeroconf, "_adb-tls-connect._tcp.local.", listener)
    global found
    found = False
    start_time = time.time()

    spinner_chars = ['-', '/', '|', '\\']
    spin_index = 0

    try:
        print("\n~ Looking for Connectios... ", end="", flush=True)
        while not found and (time.time() - start_time) < timeout:
            sys.stdout.write(spinner_chars[spin_index % len(spinner_chars)])
            sys.stdout.flush()
            time.sleep(0.1)
            sys.stdout.write("\b")
            spin_index += 1

        if not listener.services:
            print("\nError: No ADB service found.\n", file=sys.stderr)
            print("\nPlease ensure:")
            print(f"- {orange}wireless debugging{white} is enabled on your device")
            print("- Device is connected to a Wifi/Hotspot")
            print(f"\nFor support, visit: {cyan}{telegram}")
            return 1

        print("\n")

        if len(listener.services) == 1:
            info = listener.services[0]
            ip_address = socket.inet_ntoa(info.addresses[0])
            port = info.port
            print(f"Device found: {ip_address}:{port}\n")
            return attempt_adb_connect(ip_address, port)

        print("Multiple ADB devices found:\n")
        for i, info in enumerate(listener.services, 1):
            ip_address = socket.inet_ntoa(info.addresses[0])
            port = info.port
            print(f"{i}. {ip_address}:{port}")
        
        while True:
            try:
                choice = int(input("\nEnter device number: "))
                if 1 <= choice <= len(listener.services):
                    info = listener.services[choice - 1]
                    ip_address = socket.inet_ntoa(info.addresses[0])
                    port = info.port
                    print(f"Selected device: {ip_address}:{port}\n")
                    return attempt_adb_connect(ip_address, port)
                print(f"Invalid choice. Select a number between 1 and {len(listener.services)}.\n")
            except ValueError:
                print(f"For support, visit: {telegram}")

    except Exception as e:
        print(f"Error during discovery: {e}\n", file=sys.stderr)
        print(f"For support, visit: {telegram}")
        return 1
    finally:
        zeroconf.close()

def attempt_adb_connect(ip_address, port):
    command = f"adb connect {ip_address}:{port}"
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode == 0 and "connected to" in result.stdout:
            print(f"Connected with: {green}{ip_address}{white}:{green}{port}{white}\n")
            print(f"~ Use command [ {green}debloat{white} ] to start debloating...\n")
            return 0
        print(f"Failed to connect: {red}{ip_address}{white}:{red}{port}{white}", file=sys.stderr)
        print(f"Pair with <IP>:<PORT> first\n")
        return attempt_adb_pair(ip_address, port)
    except subprocess.SubprocessError as e:
        print(f"Error executing adb connect: {e}\n", file=sys.stderr)
        print(f"For support, visit: {telegram}")
        return 1

def attempt_adb_pair(connect_ip, connect_port):
    pair_ip = input(f"Enter pairing IP (default: {connect_ip}): ") or connect_ip
    pair_port = input("Enter pairing port: ")
    pairing_code = input("Enter pairing code: ")
    command = f"adb pair {pair_ip}:{pair_port} {pairing_code}"
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode == 0 and "Successfully paired" in result.stdout:
            print(f"\nPaired with: {green}{pair_ip}{white}:{green}{pair_port}{white}\n")
            return attempt_adb_connect(connect_ip, connect_port)
        print(f"\nFailed to pair: {red}{pair_ip}{white}:{red}{pair_port}{white}", file=sys.stderr)
        print("Re-check and enter Aaccurate Values\n")
        return 1
    except subprocess.SubprocessError as e:
        print(f"Error executing adb pair: {e}\n", file=sys.stderr)
        print(f"For support, visit: {telegram}")
        return 1

sys.exit(find_adb_service())
