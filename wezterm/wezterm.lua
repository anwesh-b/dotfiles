local wezterm = require 'wezterm'
local config = {}

-- Color schemes
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#222222"
custom.tab_bar.background = "#040404"
custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
custom.tab_bar.new_tab.bg_color = "#222222"

config.color_schemes = {
  ['Pancake'] = custom
}
config.color_scheme = 'Pancake'

-- Fonts and apperance
config.font = wezterm.font('SFMono Nerd Font')
config.font_size = 15
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- Ligatures
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

config.automatically_reload_config = true

-- Cursor blink style
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.window_decorations = "RESIZE"

return config

