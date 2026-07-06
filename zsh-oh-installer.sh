#!/usr/bin/env bash
#
# zsh-oh-installer — install/uninstall zsh + oh-my-zsh + plugins + fatllama theme.
# Supported: Ubuntu/Debian (apt) and macOS (system zsh, no Homebrew required).
#
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main/zsh-oh-installer.sh)"
#   ... [-- -y] [-- -t <theme>] [-- -r]
#
#   -y            install with the fatllama theme, no prompts
#   -t <theme>    install with the given theme name
#   -r            uninstall
#   -h            help
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- output helpers -------------------------------------------------------
log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() { printf '\n\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- sudo: authenticate once, keep the timestamp warm --------------------
# We never read or store the password ourselves — sudo prompts on /dev/tty and
# caches its own timestamp. This replaces the old, insecure `export PASSWD` +
# `echo $PASSWD | sudo -S` scheme.
SUDO_KEEPALIVE_PID=""
sudo_init() {
  have sudo || die "sudo not found; install it or run as root."
  log "Requesting sudo access (you will be prompted once)"
  sudo -v || die "Could not obtain sudo access."
  # ponytail: naive keep-alive loop (global bg process); killed in cleanup.
  # Ceiling: one extra process for the script's lifetime. Fine for an installer.
  ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit 0; done ) 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
}
cleanup() { [ -n "$SUDO_KEEPALIVE_PID" ] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; }
trap cleanup EXIT

# --- OS detection ---------------------------------------------------------
OS=""
detect_os() {
  case "$(uname -s)" in
    Darwin) OS="mac" ;;
    Linux)
      local id="" id_like=""
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        id="${ID:-}"; id_like="${ID_LIKE:-}"
      fi
      case "$id $id_like" in
        *ubuntu*|*debian*) OS="debian" ;;
        *) die "Only Ubuntu/Debian and macOS are supported (detected: ${id:-unknown})." ;;
      esac
      ;;
    *) die "Unsupported OS: $(uname -s). Only Ubuntu/Debian and macOS are supported." ;;
  esac
  log "Detected platform: $OS"
}

# --- install steps --------------------------------------------------------
ensure_zsh() {
  if have zsh; then log "zsh already installed"; return; fi
  case "$OS" in
    debian)
      log "Installing zsh via apt"
      sudo apt-get update -y
      sudo apt-get install -y zsh
      ;;
    mac)
      # macOS 10.15+ ships zsh at /bin/zsh by default — no Homebrew needed.
      die "zsh not found. Modern macOS ships zsh by default; install it manually and re-run."
      ;;
  esac
}

ensure_deps() {
  case "$OS" in
    debian)
      log "Installing dependencies (git curl)"
      sudo apt-get install -y git curl
      ;;
    mac)
      # git triggers the Xcode Command Line Tools install prompt if missing.
      have git || die "git not found. Run 'xcode-select --install' and re-run."
      have curl || die "curl not found (unexpected on macOS)."
      ;;
  esac
}

install_omz() {
  if [ -d "$HOME/.oh-my-zsh" ]; then log "oh-my-zsh already present, skipping"; return; fi
  log "Installing oh-my-zsh (unattended)"
  # --unattended: no chsh, no launching a subshell, keeps going non-interactively.
  # We manage .zshrc and the shell change ourselves below.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# clone (or update) a git repo into a destination
clone_or_update() {
  local url="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    log "Updating ${dest##*/}"
    git -C "$dest" pull --ff-only || warn "Could not fast-forward ${dest##*/}, leaving as-is."
  else
    log "Cloning ${url##*/}"
    git clone --depth=1 "$url" "$dest"
  fi
}

install_plugins() {
  mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"
  clone_or_update https://github.com/zsh-users/zsh-autosuggestions        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_or_update https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
  clone_or_update https://github.com/MichaelAquilina/zsh-you-should-use    "$ZSH_CUSTOM/plugins/you-should-use"
  clone_or_update https://github.com/supercrabtree/k                       "$ZSH_CUSTOM/plugins/k"
  # Dim the too-bright default directory color in `k`. -i.bak works on both GNU and BSD sed.
  if [ -f "$ZSH_CUSTOM/plugins/k/k.sh" ]; then
    sed -i.bak 's/K_COLOR_DI="0;34"/K_COLOR_DI="0;94"/g' "$ZSH_CUSTOM/plugins/k/k.sh"
    rm -f "$ZSH_CUSTOM/plugins/k/k.sh.bak"
  fi
  log "Downloading fatllama theme"
  curl -fsSL "$REPO_RAW/themes/fatllama.zsh-theme" -o "$ZSH_CUSTOM/themes/fatllama.zsh-theme"
}

install_fzf() {
  case "$OS" in
    debian)
      log "Installing fzf via apt"
      sudo apt-get install -y fzf
      ;;
    mac)
      # Homebrew-free install: clone + prebuilt binary. --no-update-rc keeps our
      # .zshrc authoritative; it generates ~/.fzf.zsh which the .zshrc sources.
      if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
      fi
      "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
      ;;
  esac
}

set_default_shell() {
  local zbin; zbin="$(command -v zsh)"
  # zsh must be listed in /etc/shells for chsh to accept it.
  if ! grep -qxF "$zbin" /etc/shells 2>/dev/null; then
    log "Adding $zbin to /etc/shells"
    echo "$zbin" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "${SHELL:-}" = "$zbin" ]; then
    log "Default shell already zsh"
    return
  fi
  log "Changing default shell to zsh"
  chsh -s "$zbin" || warn "chsh failed. Change it manually: chsh -s $zbin"
}

install_zshrc() {
  local theme="$1" url
  case "$OS" in
    debian) url="$REPO_RAW/zshrc/.zshrc-linux" ;;
    mac)    url="$REPO_RAW/zshrc/.zshrc-mac" ;;
  esac
  if [ -f "$HOME/.zshrc" ]; then
    local bak
    bak="$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.zshrc" "$bak"
    log "Backed up existing .zshrc to $bak"
  fi
  log "Downloading .zshrc for $OS"
  curl -fsSL "$url" -o "$HOME/.zshrc"
  # Fill installer placeholders (robust — no line-number-based sed injection).
  sed -i.bak "s|__ZSH_USER_M__|$HOME|g; s|__ZSH_DEFAULT_THEME__|$theme|g" "$HOME/.zshrc"
  rm -f "$HOME/.zshrc.bak"
  log "Theme set to: $theme"
}

# --- uninstall ------------------------------------------------------------
uninstall() {
  have zsh || die "zsh not found — nothing to uninstall."
  sudo_init
  if have uninstall_oh_my_zsh; then
    uninstall_oh_my_zsh --unattended 2>/dev/null || true
  fi
  rm -rf "$HOME/.oh-my-zsh"
  rm -f "$HOME/.zshrc" "$HOME"/.zcompdump*
  local bbin; bbin="$(command -v bash)"
  log "Reverting default shell to bash"
  chsh -s "$bbin" 2>/dev/null || warn "chsh failed. Change it manually: chsh -s $bbin"
  case "$OS" in
    debian)
      read -rp "Remove the zsh package from the system too? [y/N]: " ans
      if [[ "$ans" =~ ^[Yy]$ ]]; then
        sudo apt-get remove -y zsh
      else
        log "Kept the zsh package; removed only oh-my-zsh and config."
      fi
      ;;
    mac)
      log "Left system zsh in place (it is the macOS default)."
      ;;
  esac
  log "Done. Start a new session (or logout/login) for the shell change to take effect."
}

# --- theme selection ------------------------------------------------------
choose_theme() {
  # Priority: explicit -t, then -y default, then interactive prompt.
  if [ -n "${OPT_THEME:-}" ]; then
    THEME="$OPT_THEME"
  elif [ -n "${OPT_EASY:-}" ]; then
    THEME="fatllama"
  else
    read -rp "Preferred theme [default: fatllama]: " THEME
    THEME="${THEME:-fatllama}"
  fi
}

install() {
  sudo_init
  ensure_deps
  ensure_zsh
  install_omz
  install_plugins
  install_fzf
  choose_theme
  install_zshrc "$THEME"
  set_default_shell
  log "Done. Start a new session (or logout/login) for changes to take effect."
}

usage() {
  sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# --- entrypoint -----------------------------------------------------------
OPT_EASY=""; OPT_THEME=""; OPT_REMOVE=""
while getopts ":yrt:h" opt; do
  case "$opt" in
    y) OPT_EASY=1 ;;
    t) OPT_THEME="$OPTARG" ;;
    r) OPT_REMOVE=1 ;;
    h) usage ;;
    \?) die "Unknown option: -$OPTARG" ;;
    :)  die "Option -$OPTARG requires an argument." ;;
  esac
done

detect_os

if [ -n "$OPT_REMOVE" ]; then
  ACTION="uninstall"
elif [ -n "$OPT_EASY" ] || [ -n "$OPT_THEME" ]; then
  ACTION="install"
else
  while true; do
    read -rp "Install or uninstall zsh? [1=install / 2=uninstall]: " choice
    case "$choice" in
      1|'') ACTION="install"; break ;;
      2)    ACTION="uninstall"; break ;;
      *)    echo "Please answer 1 or 2." ;;
    esac
  done
fi

case "$ACTION" in
  install)   install ;;
  uninstall) uninstall ;;
esac
