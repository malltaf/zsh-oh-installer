# zsh-oh-installer

Installer for **zsh + oh-my-zsh** with a curated, performance-tuned setup:
plugins, the [fatllama](themes/fatllama.md) theme, and sane defaults.

Supported platforms: **Ubuntu/Debian** and **macOS** (Homebrew-free).

## Getting started

### Prerequisites
- Ubuntu/Debian or macOS
- `curl` and `git` (on macOS, `git` comes from Xcode Command Line Tools:
  `xcode-select --install`)

### Install
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main/zsh-oh-installer.sh)"
```
The script asks whether to install or uninstall and which theme to use.

### Options
| Flag | Meaning | Priority |
|------|---------|----------|
| `-y` | install with the `fatllama` theme, no prompts | low |
| `-t <theme>` | install with the given theme | high |
| `-r` | uninstall | highest |
| `-h` | help | — |

Pass flags after `--`:
```
bash -c "$(curl -fsSL .../zsh-oh-installer.sh)" -- -y -t fatllama
bash -c "$(curl -fsSL .../zsh-oh-installer.sh)" -- -r
```

### Install with base tools (git/curl/micro + micro config)
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main/allsoftinstall.sh)"
```

### Uninstall
`-r` removes oh-my-zsh and `~/.zshrc`, reverts the login shell to bash, and asks
whether to remove the `zsh` package. On macOS the system `zsh` is left in place.

## What it sets up

**Plugins:** `command-not-found git last-working-dir sudo wd zsh-autosuggestions
k you-should-use fast-syntax-highlighting` (+ `macos` on macOS).
`fast-syntax-highlighting` is kept last on purpose (it wraps ZLE widgets).

**Downloadable plugins/tools** (cloned from upstream at install time, not vendored):
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
- [zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)
- [k](https://github.com/supercrabtree/k)
- [fzf](https://github.com/junegunn/fzf) — Ctrl+R history, Ctrl+T files, Alt+C cd
  (apt on Debian; Homebrew-free clone on macOS)

**Performance tuning baked into `.zshrc`:**
- lazy-loaded `nvm` (saves ~300-400ms/start)
- deferred, guarded Yandex Cloud completion (skipped if not present)
- `ZSH_DISABLE_COMPFIX` to skip the compaudit scan
- a fix for slow bracketed pasting (oh-my-zsh's `bracketed-paste-magic`)
- `git_current_branch` in the theme instead of `git status` on every prompt

## Notes on sudo
The script uses `sudo` only where required (package install, adding zsh to
`/etc/shells`, `chsh`). It authenticates once via `sudo -v` and lets sudo manage
its own timestamp — the password is **never** read, stored, or exported by the
script.

## Testing
Static checks (syntax + shellcheck):
```
./test.sh
```
Runtime: last verified on Ubuntu (WSL) and current macOS.

## License
GPL-3.0 (see [LICENSE](LICENSE)).
