# Android/OEM De-Bloater

## Overview
The **Android/OEM De-Bloater** is designed to help users easily uninstall unwanted applications (bloatware) from their Android devices. This script works in Termux, a terminal emulator for Android, allowing users to manage any installed applications efficiently through ADB Shell.

## Features
- **Detects Connected Devices**: Automatically identifies the connected Android device's brand.
- **Bloatware List**: Uses a predefined list of common bloatware for various brands.
- **User-Friendly Interface**: Interacts with the user through a simple command-line interface, providing clear instructions and feedback.
- **Multi-Action Support**: Allows users to uninstall, disable, enable, or reinstall applications.
- **Backup and Restore**: Optionally retains data for app restoration.

## Requirements
- **Termux**: Install Termux from [GitHub](https://github.com/termux/termux-app/releases) OR [F-Droid](https://f-droid.org/packages/com.termux/)
- **WiFi/Hotspot**: Must be connecteed to a WiFi or Hotspot Network
- **Python 3**: Already Included
- **Android-Tools**: Already Included

## Installation
- **From Termux command line:**

1 - Primary Installation
```bash
curl -sS https://raw.githubusercontent.com/SPEED-OX/debloate/main/install.sh | bash
```
2 - ADB Shell Connection

> Replace < *ip* > with < *localhost* > if same device connection

> Open settings>develoer options>wireless debugging>pair device using pairing code

```bash
adb pair <ip>:<port> <pairing_code>
```
```bash
adb connect <ip>:<port>
```
3 - Run The Tool
```bash
debloat
```

## Help & Support
- **Telegram**: [![Telegram Channel](https://img.shields.io/badge/-telegram-red?color=white&logo=telegram&logoColor=blue)](https://t.me/TechGeekZ_CH)
- **YouTube**:
