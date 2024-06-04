#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root or with sudo."
  exit 1
fi

# Tmux & Nvim
bash scripts/tmuxSetup
bash scripts/nvim

bash scripts/hcloud_k9s
bash scripts/gh

pip install ansible

DRIVER_URL="https://repo.radeon.com/amdgpu-install/23.40.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb"

# Prompt the user for confirmation
read -p "Do you want to download the driver from $DRIVER_URL? (y/n): " response

# Check the user's response
if [[ "$response" == "y" || "$response" == "Y" ]]; then
    # Download the driver using wget
    wget $DRIVER_URL -O amdgpu-install_6.0.60002-1_all.deb
    echo "Download completed."
else
    echo "Download canceled."
fi
