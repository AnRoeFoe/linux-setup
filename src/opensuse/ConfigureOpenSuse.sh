#!/bin/bash

# ============================================================================
# Sets up a fresh openSUSE Tumbleweed (GNOME) system with the same tools as
# ConfigureFedora.sh, plus the niri compositor with DankMaterialShell (dms).
# Helper files (Git script, shortcuts, fonts) are shared with ../fedora.
# ============================================================================

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
readonly FEDORA_DIR="$SCRIPT_DIR/../fedora"

zyp() { sudo zypper --non-interactive "$@"; }

echo "==> Configuring Git"
"$FEDORA_DIR/configure_git.sh"

echo "==> Installing and configuring snapper"
zyp install snapper
# Tumbleweed's default btrfs layout usually ships a root config already.
sudo snapper list-configs | grep -qw root || sudo snapper -c root create-config /
sudo snapper -c root create -d "Initial snapshot of root filesystem"
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

echo "==> Installing core CLI and desktop tools"
zyp install kitty neovim stow fastfetch gummi btrfs-assistant starship wget flatpak

echo "==> Installing Flatpak applications"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install --system --assumeyes flathub \
  org.keepassxc.KeePassXC md.obsidian.Obsidian com.rafaelmardojai.Blanket

echo "==> Installing Visual Studio Code"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
printf '%s\n' \
  "[code]" \
  "name=Visual Studio Code" \
  "baseurl=https://packages.microsoft.com/yumrepos/vscode" \
  "enabled=1" \
  "autorefresh=1" \
  "type=rpm-md" \
  "gpgcheck=1" \
  "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
  | sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null
sudo zypper --non-interactive --gpg-auto-import-keys refresh
zyp install code

echo "==> Installing niri and DankMaterialShell"
zyp install niri
# Official DankMaterialShell installer; supports openSUSE Tumbleweed.
curl -fsSL https://install.danklinux.com | sh

echo "==> Configuring GNOME shortcuts"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"
dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ \
  < "$FEDORA_DIR/custom_shortcuts.txt"

echo "==> Applying dotfiles"
git clone https://github.com/AnRoeFoe/dotfiles.git ~/.repositories/dotfiles
(
  cd ~/.repositories/dotfiles
  for pkg in starship kitty inputrc bashrc.d; do
    stow -t ~ "$pkg"
  done
)

echo "==> Installing LazyVim starter"
git clone https://github.com/LazyVim/starter ~/.config/nvim

echo "==> Installing FiraCode Nerd Font"
mkdir -p ~/.local/share/fonts/FiraCode
cp "$FEDORA_DIR"/fonts/FiraCode/* ~/.local/share/fonts/FiraCode
fc-cache -f

echo "==> Installing Copilot app"
mkdir -p ~/.local/bin
wget -O ~/.local/bin/copilot-app-linux https://gh.io/copilot-app-linux
chmod u+x ~/.local/bin/copilot-app-linux

sudo snapper -c root create -d "After ConfigureOpenSuse.sh script has completed successfully"
echo "Done. Log out and choose GNOME or niri at the login screen."
