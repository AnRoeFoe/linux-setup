#!/bin/bash

set -euo pipefail

# Install system packages and configure system-wide Fedora services.
readonly FEDORA_VERSION="$(rpm -E %fedora)"

# Install and configure snapper for the root filesystem.
sudo dnf -y install snapper
sudo snapper -c root create-config /
sudo snapper -c root create -d "Initial snapshot of root filesystem"
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# Install the core CLI and terminal utilities used for daily work.
sudo dnf -y install kitty neovim stow fastfetch gummi btrfs-assistant deja-dup

printf "\n==> Enable RPM Fusion (free and nonfree)\n"
sudo dnf -y install \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
sudo dnf -y upgrade --refresh

printf "\n==> Enable Cisco OpenH264 repo\n"
sudo dnf config-manager --set-enabled fedora-cisco-openh264 || true
sudo dnf -y upgrade --refresh

printf "\n==> Multimedia and codecs\n"
printf "Replace ffmpeg-free with ffmpeg\n"
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
sudo dnf -y install vlc || true

printf "Enable OpenH264 packages\n"
sudo dnf -y install openh264 gstreamer1-plugin-openh264 mozilla-openh264 || true

printf "Install all GStreamer plugins\n"
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} \
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

# dnf check-update uses exit status 100 when updates are available.
check_update_status=0
dnf check-update || check_update_status=$?
if [ "$check_update_status" -ne 0 ] && [ "$check_update_status" -ne 100 ]; then
  exit "$check_update_status"
fi
sudo dnf -y install code
