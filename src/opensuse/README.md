# ConfigureOpenSuse

Setup script for a fresh openSUSE Tumbleweed install with GNOME. It installs the same tools as `../fedora/ConfigureFedora.sh` and additionally the niri compositor with DankMaterialShell (`dms`).

## Usage

```bash
cd src/opensuse
./ConfigureOpenSuse.sh
```

## Prerequisites

- openSUSE Tumbleweed with GNOME
- `sudo` access and internet access

## What it does

- Git identity and credential manager (shared `../fedora/configure_git.sh`)
- `kitty`, `neovim`, `stow`, `fastfetch`, `gummi`, `btrfs-assistant`, `starship`, `code` (Microsoft zypper repo)
- Flatpaks from Flathub: KeePassXC, Obsidian, Blanket
- `niri` and DankMaterialShell; pick niri at the login screen
- GNOME shortcuts, dotfiles via `stow`, LazyVim, FiraCode Nerd Font, Copilot app

## Notes

- Shared files (`configure_git.sh`, `custom_shortcuts.txt`, `fonts/`) are read from `../fedora`, so keep the repository layout intact.
- Not idempotent; intended for a fresh machine.
