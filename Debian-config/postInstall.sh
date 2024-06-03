#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root or with sudo."
  exit 1
fi

# Tmux & Nvim
bash scripts/tmuxSetup
bash scripts/nvim

#docker
bash scripts/docker
#k8s
bash scripts/kubernetes

