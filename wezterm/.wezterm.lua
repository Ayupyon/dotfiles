local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Latte"
config.font = wezterm.font("Maple Mono NF CN")
config.adjust_window_size_when_changing_font_size = false

return config
