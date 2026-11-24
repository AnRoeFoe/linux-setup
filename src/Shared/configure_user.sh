#!/bin/bash

set -euo pipefail

# Configure GNOME and install personal files for the account running this script.
if [ "$(id -u)" -eq 0 ]; then
  printf "Run configure_user.sh as the account that should receive the user configuration.\n" >&2
  exit 1
fi

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$HOME/.repositories/dotfiles"
readonly USER_BIN_DIR="$HOME/.local/bin"

# Set up the custom keyboard shortcuts used for launching applications and closing windows.
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"

dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ \
  < "$SCRIPT_DIR/custom_shortcuts.txt"

# Clone the personal dotfiles repo and apply the relevant stow-managed configs.
mkdir -p "$HOME/.repositories"
git clone https://github.com/AnRoeFoe/dotfiles.git "$DOTFILES_DIR"
(
  cd "$DOTFILES_DIR"
  stow -t "$HOME" starship
  stow -t "$HOME" kitty
  stow -t "$HOME" inputrc
  stow -t "$HOME" bashrc.d
)

# Install the LazyVim starter configuration for Neovim.
mkdir -p "$HOME/.config"
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"

# Install the FiraCode Nerd Font.
readonly FONT_DIR="$HOME/.local/share/fonts/FiraCode"
mkdir -p "$FONT_DIR" "$USER_BIN_DIR"
cp "$SCRIPT_DIR"/fonts/FiraCode/* "$FONT_DIR"/
fc-cache -fv

wget -O "$USER_BIN_DIR/copilot-app-linux" https://gh.io/copilot-app-linux
chmod u+x "$USER_BIN_DIR/copilot-app-linux"
