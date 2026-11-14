#!/bin/sh

# Prompt for the global Git identity used for commits on this machine.
# This sets the name and email stored in the user's ~/.gitconfig.
while :; do
  # Read the Git author name from the terminal.
  printf "Git user name: "
  if ! IFS= read -r git_name; then
    printf "Failed to read Git user name.\n" >&2
    exit 1
  fi

  # Read the Git author email from the terminal.
  printf "Git user email: "
  if ! IFS= read -r git_email; then
    printf "Failed to read Git user email.\n" >&2
    exit 1
  fi

  # Reject empty values so the Git config is never left incomplete.
  if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    printf "Git user name and email must not be empty.\n"
    continue
  fi

  # Confirm the entered identity before writing it to the global config.
  printf "Use this Git identity?\n  Name: %s\n  Email: %s\nConfirm [y/N]: " \
    "$git_name" "$git_email"
  if ! IFS= read -r confirmation; then
    printf "Failed to read confirmation.\n" >&2
    exit 1
  fi

  case "$confirmation" in
    [Yy]|[Yy][Ee][Ss])
      # Store the accepted identity in the global Git configuration.
      git config --global user.name "$git_name"
      git config --global user.email "$git_email"
      exit 0
      ;;
    *)
      printf "Please enter the Git identity again.\n"
      ;;
  esac
done

# Set default branch name for new Git repositories to "main" instead of "master".
git config --global init.defaultBranch main

# Download and install Git Credential Manager.
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v3.0.2/gcm-linux-x64-3.0.2.tar.gz
mkdir -p ~/.local/bin
tar -xzf gcm-linux-x64-3.0.2.tar.gz -C ~/.local/bin
rm gcm-linux-x64-3.0.2.tar.gz
~/.local/bin/git-credential-manager configure
git config --global credential.credentialStore secretservice