#!/bin/bash

if [ -x "$(command -v nvim)" ]; then
    sudo rm -rf /usr/local/bin/nvim
    sudo rm -rf /usr/bin/nvim
    sudo rm -rf /usr/local/share/nvim
    sudo rm -rf /usr/share/nvim
fi

temp_dir=$(mktemp -d)

cd "$temp_dir"

curl -sSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz | sudo tar -xz -C /usr/local --strip-components=1

sudo ln -s /usr/local/bin/nvim /usr/bin/nvim

echo "Neovim setup complete."

rm -rf "$temp_dir"
