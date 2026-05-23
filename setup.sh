#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()    { echo -e "${GREEN}==> $*${NC}"; }
warn()   { echo -e "${YELLOW}==> $*${NC}"; }

# Create a symlink, backing up any existing non-symlink file
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up existing $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  log "Linked $dst -> $src"
}

# ── Symlinks ────────────────────────────────────────────────────────────────
log "Linking configs..."
link "$DOTFILES_DIR/nvim"                  "$HOME/.config/nvim"
link "$DOTFILES_DIR/wezterm/wezterm.lua"   "$HOME/.config/wezterm/wezterm.lua"
link "$DOTFILES_DIR/tmux/tmux.conf"        "$HOME/.tmux.conf"
link "$DOTFILES_DIR/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"

# ── TPM ─────────────────────────────────────────────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TPM_DIR/.git" ]; then
  log "Updating TPM..."
  git -C "$TPM_DIR" pull --ff-only
else
  log "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

log "Installing/updating tmux plugins..."
"$TPM_DIR/bin/install_plugins"
"$TPM_DIR/bin/update_plugins" all

log "Done."
