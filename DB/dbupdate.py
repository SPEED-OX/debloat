#!/usr/bin/env python3

"""
Android/OEM Debloat Updater
This script checks for updates from GitHub and updates files that have changed.
"""

import os
import sys
import json
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError
from datetime import datetime
from os import get_terminal_size

version = "1.0"
telegram = "https://t.me/TechGeekZ_chat"


red = '\033[91m'
cyan = '\033[96m'
white = '\033[0m'
green = '\033[92m'
yellow = '\033[93m'


width = get_terminal_size().columns
l1 = '─' * width
l2 = '-' * width


def get_install_dir():
    script_dir = Path(__file__).parent.resolve()
    install_dir = script_dir.parent
    return install_dir


def fetch_url(url, timeout=30):
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Android-Debloater-Update-Checker)',
            'Accept': 'application/vnd.github.v3+json'
        }
        req = Request(url, headers=headers)
        with urlopen(req, timeout=timeout) as response:
            return response.read()
    except HTTPError as e:
        if e.code == 404:
            print(f"{red}[Error]{white} Resource not found (404): {url}")
        elif e.code == 403:
            print(f"{red}[Error]{white} Access forbidden (403) - possible rate limit")
        else:
            print(f"{red}[Error]{white} HTTP Error {e.code}: {e.reason}")
        return None
    except URLError as e:
        print(f"{red}[Error]{white} URL Error: {e.reason}")
        return None
    except Exception as e:
        print(f"{red}[Error]{white} Failed to fetch URL: {e}")
        return None


def check_internet_connection():
    try:
        urlopen('https://www.google.com', timeout=5)
        return True
    except:
        return False


def get_latest_commit_sha():
    url = "https://api.github.com/repos/SPEED-OX/debloat/commits/main"
    content = fetch_url(url)
    
    if content:
        try:
            data = json.loads(content.decode('utf-8'))
            return data['sha']
        except Exception as e:
            print(f"{red}[Error]{white} Failed to parse commit data: {e}")
    
    return None


def get_file_from_github(file_path):
    url = f"https://raw.githubusercontent.com/SPEED-OX/debloat/main/{file_path}"
    return fetch_url(url)


def get_update_info():
    info_file = get_install_dir() / '.update_info'
    
    if not info_file.exists():
        return None
    
    try:
        with open(info_file, 'r') as f:
            return json.load(f)
    except json.JSONDecodeError:
        print(f"{yellow}[Warning]{white} .update_info file is corrupted")
        return None
    except Exception as e:
        print(f"{yellow}[Warning]{white} Failed to read .update_info: {e}")
        return None


def save_update_info(commit_sha):
    info_file = get_install_dir() / '.update_info'
    
    data = {
        'last_commit_sha': commit_sha,
        'last_update_time': datetime.now().isoformat(),
        'version': version
    }
    
    try:
        with open(info_file, 'w') as f:
            json.dump(data, f, indent=2)
        return True
    except Exception as e:
        print(f"{red}[Error]{white} Failed to save .update_info: {e}")
        return False


def get_local_commit_sha():
    update_info = get_update_info()
    
    if update_info:
        return update_info.get('last_commit_sha')
    
    return None


def get_changed_files(base_commit, head_commit):
    url = f"https://api.github.com/repos/SPEED-OX/debloat/compare/{base_commit}...{head_commit}"
    
    try:
        content = fetch_url(url)
        if not content:
            return None
        
        data = json.loads(content.decode('utf-8'))
        
        changed_files = []
        
        relevant_paths = ['DB/', 'lists/']
        
        for file_info in data.get('files', []):
            filename = file_info['filename']
            status = file_info['status']
            
            if any(filename.startswith(path) or filename == path for path in relevant_paths):
                changed_files.append({
                    'path': filename,
                    'status': status,
                    'additions': file_info.get('additions', 0),
                    'deletions': file_info.get('deletions', 0)
                })
        
        return changed_files
    
    except Exception as e:
        print(f"{red}[Error]{white} Failed to get changed files: {e}")
        return None


def compare_and_update_files(force=False):
    install_dir = get_install_dir()
    
    print(f"{green}~{white} Checking for updates...")
    print(l2)
    
    if not check_internet_connection():
        print(f"\n{red}[Error]{white} No internet connection detected.")
        print(f"{red}[Error]{white} Please check your network connection and try again.\n")
        return False
    
    local_commit = get_local_commit_sha()
    
    if not local_commit:
        print(f"\n{red}[Error]{white} Installation appears to be incomplete or corrupted!")
        print(f"\n{yellow}[Info]{white} Please reinstall using:")
        print(f"\n→{green} curl -sS https://raw.githubusercontent.com/SPEED-OX/debloat/main/install.sh | bash{white}\n")
        return False
    
    latest_commit = get_latest_commit_sha()
    if not latest_commit:
        print(f"\n{red}[Error]{white} Failed to fetch latest version from GitHub.")
        print(f"{yellow}[Info]{white} Please check your internet connection or try again later.\n")
        return False
    
    print(f"\n{green}~{white} Remote commit: {cyan}{latest_commit[:7]}{white}")
    print(f"{green}~{white} Local commit:  {cyan}{local_commit[:7]}{white}")
    
    if not force and local_commit == latest_commit:
        print(f"\n{green}✓{white} You are already running the latest version!")
        print(f"{green}✓{white} No updates available.\n")
        return True
    
    print(f"\n{green}~{white} Fetching list of changed files...")
    changed_files = get_changed_files(local_commit, latest_commit)
    
    files_to_update = []
    
    if changed_files is not None:
        for file_info in changed_files:
            path = file_info['path']
            status = file_info['status']
            
            if status == 'removed':
                print(f"{yellow}[Info]{white} {path} was removed from repository (skipping)")
                continue
            
            files_to_update.append((path, status))
        
        if not files_to_update:
            print(f"\n{green}✓{white} No relevant files changed!")
            print(f"{green}✓{white} All files are up to date.\n")
            save_update_info(latest_commit)
            return True
        
        print(f"{green}~{white} Fetch result: {yellow}{len(files_to_update)}{white} files are modified")
    else:
        print(f"\n{red}[Error]{white} Could not fetch changed files from GitHub.")
        print(f"{yellow}[Info]{white} Please try again later.\n")
        return False
    
    print(f"\n{l2}")
    print(f"\n{green}~{white} Total of {yellow}{len(files_to_update)}{white} files need update...")
    print(f"{green}{l1}{white}")
    
    for idx, (filepath, status) in enumerate(files_to_update, 1):
        if status == 'added':
            status_color = green
        elif status == 'modified':
            status_color = yellow
        elif status == 'removed':
            status_color = red
        else:
            status_color = cyan
        
        print(f"{green}{idx:2d}.{white} {filepath} ({status_color}{status}{white})")
    
    print(f"{green}{l1}{white}")
    
    if not force:
        confirm = input(f"\n{green}~{white} Proceed with update? ({green}y{white}/{red}n{white}): ").strip().lower()
        if confirm not in ['y', 'yes']:
            print(f"\n{yellow}[Info]{white} Update cancelled by user!\n")
            return False
    
    print(f"\n{green}~{white} Updating files...")
    print(l2)
    
    success_count = 0
    failed_count = 0
    
    for filepath, status in files_to_update:
        local_path = install_dir / filepath
        
        print(f"\n{cyan}→{white} Updating: {filepath}")
        content = get_file_from_github(filepath)
        
        if content is None:
            print(f"  {red}✗{white} Failed to download")
            failed_count += 1
            continue
        
        local_path.parent.mkdir(parents=True, exist_ok=True)
        
        try:
            with open(local_path, 'wb') as f:
                f.write(content)
            
            if filepath.endswith('.py') or filepath.endswith('.sh') or 'debloat' in filepath:
                os.chmod(local_path, 0o755)
            
            print(f"  {green}✓{white} Updated successfully")
            success_count += 1
        except Exception as e:
            print(f"  {red}✗{white} Failed to write: {e}")
            failed_count += 1
    
    if success_count > 0:
        if save_update_info(latest_commit):
            print(f"\n{green}✓{white} Updated .update_info")
        else:
            print(f"\n{yellow}[Warning]{white} Failed to update .update_info")
    
    l3 = ' ' * ((width - 10) // 2)
    print(f"\n{l1}")
    
    print(f"{l1}")
    print(f"\n{green}✓ SUCCESS{white}: {success_count}")
    
    if failed_count > 0:
        print(f"{red}✗ FAILED:{white}  {failed_count}")
        print(f"\n{yellow}[Info]{white} Some files failed to update.")
        print(f"{yellow}[Info]{white} For troubleshooting, visit: {cyan}{telegram}{white}")
    else:
        print(f"\n{green}✓{white} All files updated successfully!")
    
    print()
    return success_count > 0


def check_updates_only():
    print(f"\n{green}~{white} Checking for updates...")
    print(l2)
    
    if not check_internet_connection():
        print(f"\n{red}[Error]{white} No internet connection detected.")
        print(f"{red}[Error]{white} Please check your network connection.\n")
        return False
    
    local_commit = get_local_commit_sha()
    
    if not local_commit:
        print(f"\n{red}[Error]{white} Installation appears to be incomplete or corrupted!")
        print(f"\n{yellow}[Info]{white} Please reinstall using:")
        print(f"\n→{green} curl -sS https://raw.githubusercontent.com/SPEED-OX/debloat/main/install.sh | bash{white}\n")
        return False
    
    latest_commit = get_latest_commit_sha()
    
    if not latest_commit:
        print(f"\n{red}[Error]{white} Failed to fetch latest version from GitHub.\n")
        return False
    
    print(f"\n{green}~{white} Remote commit: {cyan}{latest_commit[:7]}{white}")
    print(f"{green}~{white} Local commit:  {cyan}{local_commit[:7]}{white}")
    
    if local_commit == latest_commit:
        print(f"\n{green}✓{white} You are running the latest version!")
        print(f"{green}✓{white} No updates available.\n")
    else:
        print(f"\n{yellow}!{white} Updates are available!")
        print(f"{green}~{white} Checking what changed...")
        changed_files = get_changed_files(local_commit, latest_commit)
        
        if changed_files:
            print(f"\n{green}~{white} Changed files:")
            for file_info in changed_files:
                status = file_info['status']
                if status == 'added':
                    color = green
                elif status == 'modified':
                    color = yellow
                else:
                    color = red
                print(f"  {color}•{white} {file_info['path']} ({color}{status}{white})")
        
        print(f"\n{yellow}!{white} Run '{green}debloat --update{white}' to update.\n")
    
    return True


def main():
    os.system("cls" if os.name == "nt" else "clear")
    
    args = sys.argv[1:]
    
    if '-c' in args or '--check' in args:
        check_updates_only()
        return
    
    force = '-f' in args or '--force' in args
    
    title = 'Android/OEM Debloat Updater'
    l3 = '─' * ((width - len(title)) // 2)
    extra = '─' if (width - len(title)) % 2 != 0 else ''
    
    print(f"\n{l3}{green}{title}{white}{l3}{extra}")
    print(f"\n{green}Version{white}  : {green}{version}{white}")
    print("Author   : TechGeekZ")
    print(f"{cyan}Telegram{white} : {cyan}{telegram}{white}\n")
    print(l2)
    
    success = compare_and_update_files(force=force)
    
    if success:
        #print(f"{green}~{white} Update completed successfully!")
        print(f"{green}~{white} You can now run '{green}debloater{white}' to use the updated version.\n")
    else:
        print(f"{red}[Error]{white} Update failed or was cancelled!")
        print(f"~ For support, visit: {cyan}{telegram}{white}\n")
        print(l2)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{yellow}[Info]{white} Update cancelled by user!\n")
        sys.exit(0)
    except Exception as e:
        print(f"\n{red}[Error]{white} Unexpected error: {e}")
        print(f"{yellow}[Info]{white} For support, visit: {cyan}{telegram}{white}\n")
        sys.exit(1)
