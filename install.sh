prompt_install() {
  local cmd="$1"
  local pkg="$2"
  read -r "reply?Install $pkg? [y/N] "
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    brew install $cmd "$pkg"
  fi
}

# Core
prompt_install "" tmux
prompt_install "" ripgrep
prompt_install "" nvim
prompt_install "--cask" wezterm
prompt_install "--cask" nikitabobko/tap/aerospace

# Other
prompt_install "" claude-code
prompt_install "" lazygit
