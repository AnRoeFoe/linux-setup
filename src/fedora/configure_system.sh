#!/bin/bash

set -euo pipefail

# Install system packages and configure system-wide Fedora services.
readonly FEDORA_VERSION="$(rpm -E %fedora)"

# 1. Install and configure snapper, then create the initial snapshot.
sudo dnf -y install snapper
sudo snapper -c root create-config /
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
sudo snapper -c root create -d "Initial snapshot of root filesystem"

# 2. Add and enable third-party repositories.
printf "\n==> Enable RPM Fusion (free and nonfree)\n"
sudo dnf -y install \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"

printf "\n==> Enable Cisco OpenH264 repo\n"
sudo dnf config-manager --set-enabled fedora-cisco-openh264

printf "\n==> Add Terra repository\n"
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

# Configure the Microsoft package repository so VS Code can be installed
# via Fedora's package manager.
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
printf '%s\n' \
  '[code]' \
  'name=Visual Studio Code' \
  'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
  'enabled=1' \
  'autorefresh=1' \
  'type=rpm-md' \
  'gpgcheck=1' \
  'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' |
  sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

# 3. Install packages via dnf.
sudo dnf -y upgrade --refresh

# Install the core CLI and terminal utilities used for daily work.
sudo dnf -y install kitty neovim stow fastfetch gummi btrfs-assistant deja-dup code starship

printf "\n==> Multimedia and codecs\n"
printf "Replace ffmpeg-free with ffmpeg\n"
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

printf "Enable OpenH264 packages\n"
printf "Install all GStreamer plugins\n"
sudo dnf -y install vlc openh264 gstreamer1-plugin-openh264 mozilla-openh264 gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-libav lame\* --exclude=gstreamer1-plugins-bad-free-devel

# 4. Install packages via Flatpak.
sudo flatpak install --system --assumeyes flathub md.obsidian.Obsidian com.rafaelmardojai.Blanket org.keepassxc.KeePassXC
