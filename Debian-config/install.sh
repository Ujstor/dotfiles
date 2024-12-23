#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Making .config and Moving config files and background to Pictures
cd $builddir
mkdir -p /home/$username/.fonts
chown -R $username:$username /home/$username

# Installing Essential Programs 
nala install feh kitty tmux rofi picom thunar nitrogen lxpolkit x11-xserver-utils unzip wget pipewire wireplumber pavucontrol build-essential libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev zoxide xdg-utils xorg -y
# Installing Other less important Programs
nala install flameshot psmisc mangohud vim lxappearance papirus-icon-theme lxappearance fonts-noto-color-emoji gdu htop timeshift tldr git trash-cli autojump curl fzf bat python3-pip npm atril qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager policykit-1-gnome -y

virsh net-autostart default

mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git


# Installing fonts
cd $builddir 
nala install fonts-font-awesome -y
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d /home/$username/.fonts
mv dotfonts/fontawesome/otfs/*.otf /home/$username/.fonts/
chown $username:$username /home/$username/.fonts/*

# Reloading Font
fc-cache -vf
rm ./FiraCode.zip ./Meslo.zip ./JetBrainsMono.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors
./install.sh
cd $builddir
rm -rf Nordzy-cursors

# Beautiful bash
curl -LO https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.zip
unzip fastfetch-linux-amd64.zip
 mv ./fastfetch-linux-amd64/usr/bin/fastfetch /usr/bin/
rm -rf fastfetch-linux-amd64.zip ./fastfetch-linux-amd64
chmod +x /usr/bin/fastfetch
bash scripts/bashSetup

bash scripts/go
bash scripts/brave

#docke
bash scripts/docker
#k8s
bash scripts/kubernetes

#mount scripts
cp scripts/mount-menu.sh /usr/local/bin
chmod a+x /usr/local/bin/mount-menu.sh
cp scripts/umount-menu.sh /usr/local/bin
chmod a+x /usr/local/bin/umount-menu.sh

#nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) -y

bash scripts/rust

#nvidia drivers & cuda
#bash scripts/nvidia-cuda

# DWM Setup
cd ..
cd dwm
bash setup.sh
make clean install
cp dwm.desktop /usr/share/xsessions
cd $builddir
