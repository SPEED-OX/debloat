#!/data/data/com.termux/files/usr/bin/bash

# Android/OEM Bloatware Remover - Installation Script
# Author : TechGeekZ
version="1.2"

green='\033[92m'; red='\033[91m'; cyan='\033[96m'; white='\033[0m'
repo="https://github.com/SPEED-OX/debloat"
inst_dir="$HOME/android-debloater"
users_ok="$inst_dir/.installed"
export DEBIAN_FRONTEND=noninteractive

mkdir -p "$inst_dir"
LOG="$inst_dir/debloater.log"
exec > >(tee -a "$LOG") 2>&1
exec 5>>"$LOG"

run_log() {
  echo ">>> $*" >&5
  "$@" 1>&5 2>&5
}

echo

if [ ! -d "/data/data/com.termux" ]; then
  echo -e "\n${red}This installer is designed for Termux only!${white}"
  echo -e "${red}Please install Termux from F-Droid or GitHub and run the installer in Termux environment.${white}\n"
  exit 1
fi

if [ ! -f "$users_ok" ]; then
  echo -ne "\r${green}apt upgrade${white} ..."
  run_log apt upgrade -y
  run_log curl -Is "$repo/releases/download/tracking/totalusers"
fi

echo -ne "\r${green}url check${white} ..."
main_repo=$(awk '/^deb /{print $2; exit}' /data/data/com.termux/files/usr/etc/apt/sources.list)
run_log curl -s --retry 4 --connect-timeout 10 "$main_repo"
exit_code=$?
if [ $exit_code -eq 6 ]; then
  echo -e "\n${red}Request to $main_repo failed. Please check your internet connection.${white}\n"
  exit 6
elif [ $exit_code -eq 35 ]; then
  echo -e "\n${red}The $main_repo is blocked in your current country.${white}\n"
  exit 35
fi

git_repo="https://raw.githubusercontent.com"
run_log curl -s --retry 4 --connect-timeout 10 "$git_repo"
exit_code=$?
if [ $exit_code -eq 6 ]; then
  echo -e "\n${red}Request to $git_repo failed. Please check your internet connection.${white}\n"
  exit 6
elif [ $exit_code -eq 35 ]; then
  echo -e "\n${red}The $git_repo is blocked in your current country.${white}\n"
  exit 35
fi

echo -ne "\r${green}apt update${white} ..."
run_log apt update

packages=(
  "python"
  "python-pip"
  "android-tools"
  "unzip"
  "ncurses-utils"
)

pip_modules=(
  "zeroconf"
)

total=6
charit=0
start_time=0

_progress() {
  charit=$((charit + 1))
  percentage=$((charit * 100 / total))
  echo -ne "\rProgress: $charit/$total ($percentage%)"
}

_progress_done() {
  percentage=$((charit * 100 / total))
  echo -ne "\rProgress: $charit/$total ($percentage%)"
  echo
  echo
  end_time=$(date +%s)
  elapsed_time=$((end_time - start_time))
  echo "Took: $elapsed_time seconds"
}

if [ -f "$users_ok" ]; then
  start_time=$(date +%s)
  echo -ne "\r${green}ensuring dependencies${white} ..."

  missing_pkgs=()
  for p in "${packages[@]}"; do
    if ! dpkg -s "$p" >/dev/null 2>&1; then
      missing_pkgs+=("$p")
    fi
  done
  if [ ${#missing_pkgs[@]} -gt 0 ]; then
    for p in "${missing_pkgs[@]}"; do
      run_log apt download "$p"
      shopt -s nullglob
      for deb in "${p}"_*.deb *.deb; do
        run_log dpkg -i "$deb"
        rm -f "$deb"
        break
      done
      shopt -u nullglob
      run_log apt install -f -y
    done
  fi
  pip_module="${pip_modules[0]}"
  if ! pip show "$pip_module" >/dev/null 2>&1; then
    run_log pip install -q "$pip_module"
  fi
  echo -ne "\r\033[K"
  charit=$((total - 1))
fi


if [ ! -f "$users_ok" ]; then
  start_time=$(date +%s)
  charit=-1

  STAGE_DIR="$inst_dir/.deb_stage"
  rm -rf "$STAGE_DIR"
  mkdir -p "$STAGE_DIR"
  pushd "$STAGE_DIR" >/dev/null
  _progress

  run_log apt download "${packages[@]}"
  shopt -s nullglob
  debs=( ./*.deb )
  if [ ${#debs[@]} -gt 0 ]; then
    run_log dpkg -i "${debs[@]}"
  fi
  shopt -u nullglob
  run_log apt install -f -y
  popd >/dev/null
  _progress

  pip_module="${pip_modules[0]}"
  if ! pip show "$pip_module" >/dev/null 2>&1; then
    run_log pip install "$pip_module"
  fi
  _progress

  cd "$HOME"
  retry_count=0
  while [ $retry_count -lt 3 ]; do
    run_log curl -L --connect-timeout 30 "${repo}/archive/refs/heads/main.zip" -o debloat.zip
    if [ -s debloat.zip ]; then
      break
    fi
    retry_count=$((retry_count + 1))
    [ $retry_count -eq 3 ] && { echo -e "\n${red}Failed to download after 3 attempts${white}\n"; exit 1; }
    sleep 2
  done
  _progress

  run_log unzip -q debloat.zip
  src_root=""
  if [ -d "$HOME/debloat-main" ]; then
    src_root="$HOME/debloat-main"
  elif [ -d "$HOME/debloat-main-master" ]; then
    src_root="$HOME/debloat-main-master"
  else
    guess=$(find "$HOME" -maxdepth 1 -type d -name "debloat-*" -print -quit)
    if [ -n "$guess" ]; then
      src_root="$guess"
    else
      src_root="$HOME/debloat-main"
    fi
  fi
  _progress

  mkdir -p "$inst_dir"
  if [ -d "$src_root/lists" ]; then
    rm -rf "$inst_dir/lists"
    run_log cp -r "$src_root/lists" "$inst_dir/"
  fi
  if [ -d "$src_root/DB" ]; then
    rm -rf "$inst_dir/DB"
    run_log cp -r "$src_root/DB" "$inst_dir/"
  fi
  if [ -d "$inst_dir/DB" ]; then
    find "$inst_dir/DB" -type f -name '*.py' -exec chmod +x {} \;
  fi

  rm -rf "$STAGE_DIR" "$HOME/debloat.zip" "$src_root"
  _progress
  touch "$users_ok"
fi

echo -ne "\r${green}creating update info${white} ..."
latest_sha=$(curl -s "https://api.github.com/repos/SPEED-OX/debloat/commits/main" | grep -m1 '"sha"' | cut -d'"' -f4)

if [ -n "$latest_sha" ]; then
  cat > "$inst_dir/.update_info" << EOF
{
  "last_commit_sha": "$latest_sha",
  "last_update_time": "$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)",
  "version": "$version"
}
EOF
else
  echo -e "\n${yellow}[Warning]${white} Failed to fetch commit SHA, .update_info not created"
fi
echo -ne "\r\033[K"


cat > "$PREFIX/bin/debloat" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
inst_dir="$HOME/android-debloater"
if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
case "$1" in
  --update)
    shift
    exec "$PY" "$inst_dir/DB/dbupdate.py" "$@"
    ;;
  --help)
    shift
    exec "$PY" "$inst_dir/DB/dbhelp.py" "$@"
    ;;
esac
exec "$PY" "$inst_dir/DB/debloater.py" "$@"
EOF
chmod +x "$PREFIX/bin/debloat"

cat > "$PREFIX/bin/adbservice" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
inst_dir="$HOME/android-debloater"
if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
exec "$PY" "$inst_dir/DB/find_adb_service.py" "$@"
EOF
chmod +x "$PREFIX/bin/adbservice"

cat > "$PREFIX/bin/debloater" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
inst_dir="$HOME/android-debloater"
green=$'\033[92m' ; red=$'\033[91m' ; white=$'\033[0m'
if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi

if [ -f "$inst_dir/DB/find_adb_service.py" ]; then
  "$PY" "$inst_dir/DB/find_adb_service.py" "$@"
else
  echo
  echo "ERROR ${red}404${white}! | Use: ${green}debloat${white} --update"
  echo
  exit 1
fi
sleep 1

ADB_BIN=""
if [ -x /system/bin/adb ]; then
  ADB_BIN=/system/bin/adb
else
  if command -v adb >/dev/null 2>&1; then
    ADB_BIN="$(command -v adb)"
  fi
fi

connected=0
if [ -n "$ADB_BIN" ]; then
  if "$ADB_BIN" devices -l 2>/dev/null | awk 'NR>1 && $2=="device"{ok=1} END{exit !ok}'; then
    connected=1
  fi
fi

if [ "$connected" -eq 1 ]; then
  read -r -p "${green}~${white} Continue Debloating (${green}y${white}/${red}n${white})?: " ans
  case "$ans" in
    y|Y) ;;
    *) echo; echo "Aborted by user! Exiting ..."; echo; exit 0 ;;
  esac
else
  echo "No ADB connection detected; skipping debloating."
  exit 1
fi

if [ -f "$inst_dir/DB/debloater.py" ]; then
  "$PY" "$inst_dir/DB/debloater.py" "$@"
else
  echo
  echo "ERROR ${red}404${white}! | Use: ${green}debloat${white} --update"
  echo
  exit 1
fi
EOF
chmod +x "$PREFIX/bin/debloater"
_progress

if [ ! -f "$users_ok" ]; then _progress_done; else _progress_done; fi

width=$(tput cols 2>/dev/null)
t1="Android/OEM Debloater Installer"
t2="Installation Successful!"
len1=${#t1}; h1=$(((width - len1) / 2))
l1=$(printf '─%.0s' $(seq 1 $h1)); if (( (width - len1) % 2 != 0 )); then l1r="${l1}─"; else l1r="${l1}"; fi
len2=${#t2}; h2=$(((width - len2) / 2))
l2=$(printf '─%.0s' $(seq 1 $h2)); if (( (width - len2) % 2 != 0 )); then l2r="${l2}─"; else l2r="${l2}"; fi

echo
echo
echo -e "${l1}${green}${t1}${white}${l1r}"
echo
echo -e "Author   : TechGeekZ"
echo -e "${green}Version${white}  : ${green}${version}${white}"
echo -e "${cyan}Telegram${white} : ${cyan}t.me/TechGeekZ_chat${white}"
echo
echo -e "${l2}${green}${t2}${white}${l2r}"
echo
echo -e "Use command: ${green}debloat${white} --help"
echo