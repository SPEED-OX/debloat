#!/data/data/com.termux/files/usr/bin/bash
set -e

required_packages=(git termux-api)
num_steps=5
current_step=0

function progress_bar() {
  percent=$(( $1 * 100 / $2 ))
  done=$(( $percent / 5 ))
  left=$(( 20 - $done ))
  done_str=$(printf '%0.s#' $(seq 1 $done))
  left_str=$(printf '%0.s-' $(seq 1 $left))
  printf "\r[%s%s] %d%%" "$done_str" "$left_str" "$percent"
}

function update_progress() {
  current_step=$((current_step + 1))
  progress_bar $current_step $num_steps
  sleep 1
}

# Step 1: Update and upgrade pkg and pip packages
echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y
update_progress

# Step 2: Install required programs
echo -e "\nInstalling required packages..."
for pkg in "${required_packages[@]}"; do
  if ! command -v $pkg >/dev/null 2>&1; then
    pkg install -y $pkg
  fi
done
update_progress

# Step 3: Check and setup storage permission
echo -e "\nChecking storage permission..."
if [ ! -d "$HOME/storage/shared" ]; then
  termux-setup-storage
  sleep 2
  if [ ! -d "$HOME/storage/shared" ]; then
    echo "Failed to gain storage permission. Please allow it in Android settings."
    exit 1
  fi
fi
update_progress

# Step 4: Check if Termux:API app is installed
# The termux-api package is a CLI tool, but the app is required for functionality
if ! pm list packages | grep -q com.termux.api; then
  echo -e "\nTermux:API app not found. Please install it from F-Droid or Play Store, then re-run this script."
  exit 1
else
  echo "\nTermux:API app detected."
fi
update_progress

# Step 5: Clone and set up Debloater project (customize URL as needed)
echo -e "\nCloning Debloater project repository..."
git clone https://github.com/<your-user>/<debloater-repo>.git
update_progress

# Finish:
echo -e "\n\nInstallation complete!"
