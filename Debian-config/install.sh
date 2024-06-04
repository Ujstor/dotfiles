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

# Making .config and Moving config files and background to Pictures
cd $builddir
chown -R $username:$username /home/$username

# Installing Essential Programs 
apt install tmux lxpolkit unzip wget build-essential zoxide -y
# Installing Other less important Programs
apt install neofetch psmisc vim gdu htop timeshift tldr git trash-cli autojump curl fzf bat python3-pip npm -y

sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old

# Beautiful bash
sudo bash scripts/bashSetup

bash scripts/go

#docke
bash scripts/docker
#k8s
bash scripts/kubernetes

#mount scripts
cp scripts/mount-menu.sh /usr/local/bin
chmod a+x /usr/local/bin/mount-menu.sh
cp scripts/umount-menu.sh /usr/local/bin
chmod a+x /usr/local/bin/umount-menu.sh

source ~/.bashrc
