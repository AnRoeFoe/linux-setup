# ConfigureFedora

This directory contains scripts for setting up a Fedora workstation and the personal configuration for the account running the setup.

## Script

- `ConfigureFedora.sh` - runs the Git, system, and user setup scripts in sequence.
- `configure_git.sh` - prompts for a global Git identity and installs Git Credential Manager for the current account.
- `configure_system.sh` - installs system packages, enables repositories, and configures snapper backups.
- `configure_user.sh` - configures GNOME and installs dotfiles, fonts, Neovim, and the Copilot app for the current account.
- `sysmaintenance.sh` - interactively performs routine system maintenance and logs its output to `~/.local/var/log/`.

## Prerequisites

- Fedora Workstation or a Fedora-based GNOME install
- `sudo` access
- Internet access
- A GitHub account or access to the public repositories used by the script
- For `sysmaintenance.sh`: `dnf`, `journalctl`, and `systemctl`

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/AnRoeFoe/ConfigureArchLinux.git
   cd ConfigureArchLinux/src/fedora
   ```

2. Run the full setup as the account that should receive the user configuration. The script uses `sudo` for system changes:

   ```bash
   ./ConfigureFedora.sh
   ```

On a workstation whose system setup is already complete, a newly created account can run the user setup after cloning this repository:

```bash
./configure_user.sh
```

### System maintenance

Run the maintenance script from this directory:

```bash
./sysmaintenance.sh
```

It prompts before cleaning the DNF package cache, removing unneeded packages,
deleting files in `~/.cache` older than 30 days, and vacuuming the system
journal to retain 7 days. It also reports failed systemd units. To include a
full system upgrade, pass `--upgrade`:

```bash
./sysmaintenance.sh --upgrade
```

Each run saves a log in `~/.local/var/log/`. Use `--help` to display the
available option.

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
- GNOME custom keybindings for common actions (user setup)
- Personal dotfiles from `https://github.com/AnRoeFoe/dotfiles.git` using `stow`
- LazyVim starter config for Neovim
- Global Git identity configured for the current account as:
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
