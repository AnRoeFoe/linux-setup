#!/bin/sh

# This script sets up a fresh Fedora system with the terminal and editor
# tools I use most often, then installs my personal shell and Git config.

# -----------------------------
# Colours (LGL style)
# -----------------------------
GREEN='\033[38;2;0;255;0m'     # #00ff00
ORANGE='\033[38;2;255;153;0m'  # #ff9900
RED='\033[38;2;255;68;68m'     # #ff4444
WHITE='\033[38;2;249;249;249m' # #f9f9f9
RESET='\033[0m'
BOLD='\033[1m'

section() { printf "\n${BOLD}${GREEN}==> %s${RESET}\n" "$1"; }
info() { printf "${WHITE}%s${RESET}\n" "$1"; }

# Resolve this script's directory and run the Git helper script.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
"$SCRIPT_DIR/configure_git.sh"

FEDORA_VERSION="$(rpm -E %fedora)"

# Install snapper
sudo dnf -y install snapper

# Create config for root
sudo snapper -c root create-config /

# Create a snapshot of the root filesystem
sudo snapper -c root create -d "Initial snapshot of root filesystem"

# Enable snapper-timeline.timer and snapper-cleanup.timer
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# Install the core CLI and terminal utilities used for daily work.
sudo dnf -y install kitty neovim stow fastfetch gummi btrfs-assistant deja-dup

section "Enable RPM Fusion (free and nonfree)"
dnf -y install \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
dnf -y upgrade --refresh

section "Enable Cisco OpenH264 repo"
dnf config-manager --set-enabled fedora-cisco-openh264 || true
dnf -y upgrade --refresh

# -----------------------------
# 7) Multimedia and codecs
# -----------------------------
section "Multimedia and codecs"

info "Replace ffmpeg-free with ffmpeg"
dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
dnf -y install vlc || true

info "Enable OpenH264 packages"
dnf -y install openh264 gstreamer1-plugin-openh264 mozilla-openh264 || true

info "Install all GStreamer plugins"
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} \
  gstreamer1-plugin-openh264 gstreamer1-libav lame\* \
  --exclude=gstreamer1-plugins-bad-free-devel || true

# Install desktop applications from their respective Flatpak remotes.
# sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install --system --assumeyes fedora org.keepassxc.KeePassXC
sudo flatpak install --system --assumeyes flathub md.obsidian.Obsidian com.rafaelmardojai.Blanket

# Add the Starship prompt repository and install the prompt itself.
sudo dnf -y copr enable atim/starship
sudo dnf -y install starship

# Configure the Microsoft package repository so VS Code can be installed
# via Fedora's package manager.
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Refresh metadata and install the editor itself.
dnf check-update
sudo dnf -y install code

# set up the custom keyboard shortcuts used for launching applications and closing windows.
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', \
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"

dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < custom_shortcuts.txt

# Clone the personal dotfiles repo and apply the relevant stow-managed configs.
git clone https://github.com/AnRoeFoe/dotfiles.git ~/.repositories/dotfiles
pushd ~/.repositories/dotfiles

stow -t ~ starship
stow -t ~ kitty
stow -t ~ inputrc
stow -t ~ bashrc.d

popd

# Install the LazyVim starter configuration for Neovim.
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Install the FiraCode Nerd Font
mkdir -p ~/.local/share/fonts/FiraCode
cp fonts/FiraCode/* ~/.local/share/fonts/FiraCode
fc-cache -fv

wget https://gh.io/copilot-app-linux
chmod u+x copilot-app-linux
mv copilot-app-linux ~/.local/bin/

sudo snapper -c root create -d "After ConfigureFedora.sh script has completed successfully"
