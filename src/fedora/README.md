# ConfigureFedora

This directory contains a Fedora workstation setup script for installing the tools and configuration used on a fresh GNOME desktop.

## Script

- `ConfigureFedora.sh` - installs system packages, configures snapper backups, sets up desktop shortcuts, and applies personal shell and Git settings.

## Prerequisites

- Fedora Workstation or a Fedora-based GNOME install
- `sudo` access
- Internet access
- A GitHub account or access to the public repositories used by the script

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/AnRoeFoe/ConfigureArchLinux.git
   cd ConfigureArchLinux/src/fedora
   ```

3. Run it:

   ```bash
   ./ConfigureFedora.sh
   ```

## What the script installs

- `snapper` and snapshot configuration for `/` and `/home`
- Core CLI and terminal tools:
  - `kitty`
  - `neovim`
  - `stow`
  - `fastfetch`
  - `gummi`
  - `btrfs-assistant`
  - `starship`
  - `code` (Visual Studio Code via Microsoft repo)
- Flatpak applications:
  - KeePassXC
  - Obsidian
  - Blanket
- GNOME custom keybindings for common actions
- Personal dotfiles from `https://github.com/AnRoeFoe/dotfiles.git` using `stow`
- LazyVim starter config for Neovim
- Global Git identity configured as:
  - `user.name = Max Mustermann`
  - `user.email = max.mustermann@web.de`
- Fira Code Nerd Font files copied into `~/.local/share/fonts/FiraCode`

## Notes

- The script assumes a GNOME desktop environment and modifies GNOME settings using `gsettings` and `dconf`.
- It creates system snapshots with `snapper` before and after setup.
- It expects the dotfiles repository to be available at `~/.repositories/dotfiles` and uses `stow` to link the relevant config directories.
- The script is intended for a fresh machine and is not designed to be idempotent in all cases.

## Related files

- `bashrc.d/` - shell customizations bundled with the setup
- `custom_shortcuts.txt` - GNOME custom keybinding definitions
- `fonts/` - bundled font resources
