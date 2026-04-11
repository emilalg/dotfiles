#!/usr/bin/env bash
# Restore the ~/.claude/ symlinks that point into this dotfiles repo.
# Idempotent: safe to re-run after a Claude Code reinstall or on a fresh machine.
set -eu

REPO="$HOME/.config/claude"
DEST="$HOME/.claude"
mkdir -p "$DEST"

link() {
  local name="$1"
  local src="$REPO/$name"
  local tgt="$DEST/$name"

  if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
    echo "ok     $tgt"
    return
  fi

  if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
    local bak="$tgt.bak-$(date +%Y%m%d-%H%M%S)"
    echo "backup $tgt -> $bak"
    mv "$tgt" "$bak"
  fi

  ln -sfn "$src" "$tgt"
  echo "link   $tgt -> $src"
}

link settings.json
link agents
link commands
link skills
