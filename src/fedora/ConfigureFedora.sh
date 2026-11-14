#!/bin/sh

# This script sets up a fresh Fedora system with the terminal and editor
# tools I use most often, then installs my personal shell and Git config.

# Install snapper
sudo dnf -y install snapper

# Create config for root and home
sudo snapper -c root create-config /

# Create a snapshot of the root filesystem
sudo snapper -c root create -d "Initial snapshot of root filesystem"

# Enable snapper-timeline.timer and snapper-cleanup.timer
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# Install the core CLI and terminal utilities used for daily work.
sudo dnf -y install kitty neovim stow fastfetch gummi btrfs-assistant deja-dup

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
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"

dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < custom_shortcuts.txt

# Clone the personal dotfiles repo and apply the relevant stow-managed configs.
git clone https://github.com/AnRoeFoe/dotfiles.git ~/.repositories/dotfiles
pushd ~/.repositories/dotfiles

stow -t ~ starship
stow -t ~ kitty
stow -t ~ inputrc
stow -t ~ bashrc.d

# Install the LazyVim starter configuration for Neovim.
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Ask for the global Git identity used for commits on this machine.
while :; do
  printf "Git user name: "
  if ! IFS= read -r git_name; then
    printf "Failed to read Git user name.\n" >&2
    exit 1
  fi

  printf "Git user email: "
  if ! IFS= read -r git_email; then
    printf "Failed to read Git user email.\n" >&2
    exit 1
  fi

  if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    printf "Git user name and email must not be empty.\n"
    continue
  fi

  printf "Use this Git identity?\n  Name: %s\n  Email: %s\nConfirm [y/N]: " \
    "$git_name" "$git_email"
  if ! IFS= read -r confirmation; then
    printf "Failed to read confirmation.\n" >&2
    exit 1
  fi

  case "$confirmation" in
    [Yy]|[Yy][Ee][Ss])
      git config --global user.name "$git_name"
      git config --global user.email "$git_email"
      break
      ;;
    *)
      printf "Please enter the Git identity again.\n"
      ;;
  esac
done

git config --global init.defaultBranch main

popd

# Install the FiraCode Nerd Font
mkdir -p ~/.local/share/fonts/FiraCode
cp fonts/FiraCode/* ~/.local/share/fonts/FiraCode
fc-cache -fv

sudo snapper -c root create -d "After ConfigureFedora.sh script has completed successfully"