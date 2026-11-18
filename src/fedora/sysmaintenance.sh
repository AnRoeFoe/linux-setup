#!/usr/bin/env bash
# ------------------------------------------------------------
# Fedora "Spring-Clean" Maintenance Script
# (interactive, abort-safe, log-to-file)
# ------------------------------------------------------------
#  - Designed for periodic housekeeping (monthly-ish)
#  - Optionally run with --upgrade to include a full system upgrade.
#  - Requires: dnf and systemd-journald.
# ------------------------------------------------------------

set -euo pipefail

# ---------- Config ---------------------------------------------------------
readonly LOG_DIR="$HOME/.local/var/log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/spring-clean-$(date +%F_%H-%M-%S).log"
readonly LOG_FILE

readonly CACHE_DAYS=30
readonly JOURNAL_RETAIN="7d"
# --------------------------------------------------------------------------

exec > >(tee -a "$LOG_FILE") 2>&1

# ---------- Helpers --------------------------------------------------------
confirm() {
  read -r -p "${1:-Are you sure? [y/N]} " ans || return 1
  [[ "$ans" =~ ^([yY][eE][sS]|[yY])$ ]]
}

announce() { printf "\n\e[1;34m==> %s\e[0m\n" "$1"; }

require_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: required command '$1' was not found." >&2
    exit 1
  fi
}

# ---------- CLI Switches ---------------------------------------------------
DO_UPGRADE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--upgrade)
      DO_UPGRADE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--upgrade]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

require_command dnf
require_command journalctl
require_command sudo

announce "Fedora Spring-Clean starting $(date)"

# ---------- 1. Optional system upgrade ------------------------------------
if "$DO_UPGRADE"; then
  announce "System upgrade (dnf)"
  sudo dnf upgrade --refresh
fi

# ---------- 2. DNF cache clean --------------------------------------------
announce "DNF cache clean"
current_cache=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1 || true)
echo "Current cache: ${current_cache:-0}"
if confirm "Clean the DNF package cache now? [y/N]"; then
  sudo dnf clean packages
fi
new_cache=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1 || true)
echo "Cache after clean: ${new_cache:-0}"

# ---------- 3. Unneeded packages ------------------------------------------
announce "Removing unneeded packages"
if confirm "Show and remove packages that dnf considers unnecessary? [y/N]"; then
  sudo dnf autoremove
else
  echo "Skipping package cleanup."
fi

# ---------- 4. $HOME/.cache prune -----------------------------------------
announce "Pruning ~/.cache (unused > $CACHE_DAYS days)"
cache_before=$(du -sh "$HOME/.cache" 2>/dev/null | cut -f1 || true)
echo "Before: ${cache_before:-0}"
if confirm "Clean ~/.cache now? [y/N]"; then
  find "$HOME/.cache" -type f -mtime +"$CACHE_DAYS" -print -delete
  find "$HOME/.cache" -type d -empty -print -delete
fi
cache_after=$(du -sh "$HOME/.cache" 2>/dev/null | cut -f1 || true)
echo "After: ${cache_after:-0}"

# ---------- 5. Journald rotate & vacuum -----------------------------------
announce "Vacuuming journald logs ($JOURNAL_RETAIN)"
journal_before=$(journalctl --disk-usage)
if confirm "Rotate and vacuum journald now? [y/N]"; then
  sudo journalctl --rotate
  sudo journalctl --vacuum-time="$JOURNAL_RETAIN"
fi
journal_after=$(journalctl --disk-usage)
echo "Journald: $journal_before  ->  $journal_after"

# ---------- 6. Failed systemd units ---------------------------------------
announce "Scanning for failed systemd services"
if systemctl --failed --quiet; then
  echo "No failed units detected."
else
  systemctl --failed --no-pager --plain
fi

announce "Spring-Clean finished in ${SECONDS}s - log saved to $LOG_FILE"
