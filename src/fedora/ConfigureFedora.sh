#!/bin/bash

set -euo pipefail

# Run the full Fedora setup from any working directory.
if [ "$(id -u)" -eq 0 ]; then
  printf "Run ConfigureFedora.sh as the account that should receive the user configuration; it uses sudo for system changes.\n" >&2
  exit 1
fi

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/configure_git.sh"
"$SCRIPT_DIR/configure_system.sh"
"$SCRIPT_DIR/configure_user.sh"

sudo snapper -c root create -d "After ConfigureFedora.sh script has completed successfully"
