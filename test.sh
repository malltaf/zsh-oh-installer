#!/usr/bin/env bash
#
# Static self-check for the installer scripts: bash syntax + shellcheck (if
# available). No frameworks, no network, no side effects.
#
set -euo pipefail
cd "$(dirname "$0")"

scripts=(zsh-oh-installer.sh allsoftinstall.sh test.sh)

fail=0
for f in "${scripts[@]}"; do
  if bash -n "$f"; then
    echo "OK  syntax: $f"
  else
    echo "ERR syntax: $f"; fail=1
  fi
done

if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -S warning "${scripts[@]}"; then
    echo "OK  shellcheck (warning level)"
  else
    echo "ERR shellcheck"; fail=1
  fi
else
  echo "..  shellcheck not installed, skipped"
fi

exit "$fail"
