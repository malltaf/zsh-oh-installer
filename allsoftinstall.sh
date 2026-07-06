#!/usr/bin/env bash
#
# allsoftinstall — convenience bootstrap: install base tools (git/curl/micro +
# micro config), then optionally run zsh-oh-installer.
# Supported: Ubuntu/Debian (apt) and macOS (Homebrew-free).
#
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main/allsoftinstall.sh)"
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\n\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# sudo: authenticate once via sudo's own prompt; never store the password.
sudo_init() {
  have sudo || die "sudo not found; install it or run as root."
  log "Requesting sudo access (you will be prompted once)"
  sudo -v || die "Could not obtain sudo access."
}

OS=""
detect_os() {
  case "$(uname -s)" in
    Darwin) OS="mac" ;;
    Linux)
      local id="" id_like=""
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release; id="${ID:-}"; id_like="${ID_LIKE:-}"
      fi
      case "$id $id_like" in
        *ubuntu*|*debian*) OS="debian" ;;
        *) die "Only Ubuntu/Debian and macOS are supported." ;;
      esac ;;
    *) die "Unsupported OS. Only Ubuntu/Debian and macOS are supported." ;;
  esac
}

install_tools() {
  case "$OS" in
    debian)
      sudo_init
      log "apt: git curl wget xclip micro"
      sudo apt-get update -y
      sudo apt-get install -y git curl wget xclip micro
      ;;
    mac)
      # Homebrew-free. git comes from Xcode CLT; micro via its official installer.
      have git || die "git not found. Run 'xcode-select --install' and re-run."
      if ! have micro; then
        log "Installing micro (Homebrew-free)"
        ( cd "$HOME" && curl -fsSL https://getmic.ro | bash )
        mkdir -p "$HOME/.local/bin"
        [ -f "$HOME/micro" ] && mv "$HOME/micro" "$HOME/.local/bin/micro"
      fi
      ;;
  esac
  log "Installing micro settings"
  mkdir -p "$HOME/.config/micro"
  curl -fsSL "$REPO_RAW/lib/micro/settings.json" -o "$HOME/.config/micro/settings.json"
}

run_zsh_installer() {
  # Pass through any args (e.g. -y -t fatllama) to the main installer.
  bash -c "$(curl -fsSL "$REPO_RAW/zsh-oh-installer.sh")" -- "$@"
}

detect_os

echo "1 - Install base tools (git/curl/micro + config)"
echo "2 - (Un)install oh-my-zsh with plugins"
echo "3 - Install both (tools + full zsh setup with fatllama theme)"
while true; do
  read -rp "Choose [1/2/3] (default 3): " choice
  case "$choice" in
    1) MODE="tools"; break ;;
    2) MODE="zsh"; break ;;
    3|'') MODE="all"; break ;;
    *) echo "Please answer 1, 2 or 3." ;;
  esac
done

case "$MODE" in
  tools) install_tools ;;
  zsh)
    while true; do
      echo "1 - Full install with fatllama theme"
      echo "2 - Uninstall oh-my-zsh"
      echo "3 - Run installer with interactive choice"
      read -rp "Choose [1/2/3] (default 1): " sub
      case "$sub" in
        1|'') run_zsh_installer -y -t fatllama; break ;;
        2)    run_zsh_installer -r; break ;;
        3)    run_zsh_installer; break ;;
        *)    echo "Please answer 1, 2 or 3." ;;
      esac
    done
    ;;
  all)
    install_tools
    run_zsh_installer -y -t fatllama
    ;;
esac
