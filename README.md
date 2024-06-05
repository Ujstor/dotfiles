## Dotfiles Debian Config

On a fresh Debian install (install only the Debian desktop environment!), remove any .bashrc and .config files that can conflict with files or dir before executing the 'stow .' command.

```bash
sudo apt install vim git stow
```

Clone the repo, cd into it, and execute:

```bash
stow .
```

This will create a symlink to the repo in your home directory. cd into Debian-config and execute:

```bash
sudo ./install.sh
```

Then, source your bash configuration:

```bash
source ~/.bashrc
```

Next, run the post-installation script:

```bash
./postInstall.sh
```

Install tmux plugins:
```bash
tmux
C-space + r # reload tmux
C-space + I # install tmux plugins
```

Logout from GNOME and choose dwm.

There is also a branch with i3 config and WSL2
