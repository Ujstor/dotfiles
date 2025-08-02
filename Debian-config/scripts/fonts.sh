#!/bin/bash

# Font Installation Script
# This script installs Nerd Fonts and Font Awesome

set -e  # Exit on any error

# Get the actual user (not root) when running with sudo
if [ "$EUID" -eq 0 ]; then
    # Running as root/sudo - get the real user
    if [ -n "$SUDO_USER" ]; then
        username="$SUDO_USER"
        user_home="/home/$username"
        user_uid=$(id -u "$username")
        user_gid=$(id -g "$username")
    else
        echo "Error: This script should be run with sudo, not as root directly"
        echo "Usage: sudo ./fonts.sh"
        exit 1
    fi
else
    # Running as regular user
    username=$(whoami)
    user_home="$HOME"
    user_uid=$(id -u)
    user_gid=$(id -g)
fi

builddir=$(pwd)
fonts_dir="$user_home/.fonts"

echo "Installing fonts for user: $username"
echo "User home directory: $user_home"
echo "Fonts will be installed to: $fonts_dir"

# Create fonts directory if it doesn't exist
mkdir -p "$fonts_dir"

# Install Font Awesome using package manager
echo "Installing Font Awesome..."
if command -v nala >/dev/null 2>&1; then
    nala install fonts-font-awesome -y
elif command -v apt >/dev/null 2>&1; then
    apt update && apt install fonts-font-awesome -y
else
    echo "Warning: Neither nala nor apt found. Skipping Font Awesome installation."
fi

cd "$builddir"

# Download and install FiraCode Nerd Font
echo "Downloading FiraCode Nerd Font..."
wget -O FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
echo "Extracting FiraCode..."
unzip -o FiraCode.zip -d "$fonts_dir"

# Download and install Meslo Nerd Font
echo "Downloading Meslo Nerd Font..."
wget -O Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
echo "Extracting Meslo..."
unzip -o Meslo.zip -d "$fonts_dir"

# Download and install JetBrainsMono Nerd Font
echo "Downloading JetBrainsMono Nerd Font..."
wget -O JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
echo "Extracting JetBrainsMono..."
unzip -o JetBrainsMono.zip -d "$fonts_dir"

# Install additional Font Awesome fonts if directory exists
if [ -d "dotfonts/fontawesome/otfs" ]; then
    echo "Installing additional Font Awesome fonts..."
    cp dotfonts/fontawesome/otfs/*.otf "$fonts_dir/" 2>/dev/null || true
fi

# Fix ownership of fonts directory and files
echo "Setting correct ownership for fonts..."
chown -R "$user_uid:$user_gid" "$fonts_dir"

# Update font cache
echo "Updating font cache..."
if [ "$EUID" -eq 0 ]; then
    # Run fc-cache as the actual user, not root
    sudo -u "$username" fc-cache -vf
else
    fc-cache -vf
fi

# Clean up downloaded files
echo "Cleaning up temporary files..."
rm -f ./FiraCode.zip ./Meslo.zip ./JetBrainsMono.zip

echo "Font installation completed successfully!"
echo "Installed fonts in: $fonts_dir"
echo "You may need to restart applications to see the new fonts."
