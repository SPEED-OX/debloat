<div align="center">
  
  # Android/OEM De-Bloater
  ---
</div>

## Overview
The **Android/OEM De-Bloater** is designed to help users easily uninstall unwanted applications (bloatware) from their Android devices. This script works in Termux, a terminal emulator for Android, allowing users to manage any installed applications efficiently through ADB Shell.

**This tool does not require any 	***<ins>root</ins>*** or ***<ins>modification</ins>*** and specially designed for ***<ins>root</ins>*** & ***<ins>non-root</ins>*** users**

---

***<ins>DISCLAIMER</ins>***: Use at your own risk. I am not responsible for anything happens to your phone for non-working **BRAIN-CELL !**

---

This project is still in an early stage of development. Check out the issues, and feel free to contribute!  :) This is a community project.
That means I need you! I'm sure you want to make this project better anyway.

## Summary

This project aims to improve privacy and battery performance by removing unnecessary and obscure system apps.
This can also contribute to improve security by reducing [the attack surface](https://en.wikipedia.org/wiki/Attack_surface).

Packages are as well documented as possible in order to provide a better
understanding of what you can delete or not. The worst issue that could happen
is removing an essential system package needed during boot causing then an unfortunate
bootloop. After about 5 failed system boots, the phone will automatically reboot
in recovery mode, and you'll have to perform a FACTORY RESET. Make a backup first!

In any case, you **CANNOT** brick your device with this software!
That's the main point, right?

## Features
- **Detects Connected Devices**: Automatically identifies the connected Android device's brand.
- **Functions**: Uninstall/Disable and Restore/Enable system packages
- **Multi-User Support**: Supports Multi-user (e.g. apps in work profiles)
- **Bloatware List**: Uses a predefined list of common bloatware for various brands.
- **User-Friendly Interface**: Interacts with the user through a simple command-line interface, providing clear instructions and feedback.
- **Multi-Action Support**: Allows users to uninstall, disable, enable, or reinstall applications.
- **Backup and Restore**: Optionally retains data for app restoration.

## Supporting Devices
---
<details>
  <summary>Click here to view supporting devices</summary>
  
- [ ] Archos
- [ ] Asus
- [ ] Blackberry
- [ ] Gionee
- [ ] LG
- [ ] Google
- [ ] iQOO
- [ ] Fairphone
- [ ] HTC
- [ ] Huawei
- [ ] Motorola
- [ ] Nokia
- [x] OnePlus
- [x] Oppo
- [x] Realme
- [ ] Samsung
- [ ] Sony
- [ ] Tecno
- [ ] TCL
- [ ] Unihertz
- [ ] Vivo/iQOO
- [ ] Wiko
- [x] Xiaomi (POCO, MI, Redmi)
- [ ] ZTE

</details>

> Request any specific **BRAND** in <space> [![Telegram Channel](https://img.shields.io/badge/-telegram-red?color=white&logo=telegram&logoColor=blue)](https://t.me/TechGeekZ_chat)
---
## Requirements
- **Termux**: Install Termux from [GitHub](https://github.com/termux/termux-app/releases) OR [F-Droid](https://f-droid.org/packages/com.termux/)
- **WiFi/Hotspot**: Must be connecteed to a WiFi or Hotspot Network
- **Python 3**: Already Included
- **Android-Tools**: Already Included

## Installation
- **From Termux command line:**

1 - Primary Installation
```
curl -sS https://raw.githubusercontent.com/SPEED-OX/debloate/main/install.sh | bash
```
2 - ADB Shell Connection

> Replace < *ip* > with < *localhost* > if same device connection

> Open settings>develoer options>wireless debugging>pair device using pairing code

```
adb pair <ip>:<port> <pairing_code>
```
```
adb connect <ip>:<port>
```
3 - Run The Tool
```
debloat
```
#
## Help & Support
<div align="center">
  
[![Telegram Channel](https://img.shields.io/badge/-telegram-red?color=white&logo=telegram&logoColor=blue)](https://t.me/TechGeekZ_CH)
