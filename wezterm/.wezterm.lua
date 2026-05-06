local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Maple Mono NF CN")
config.adjust_window_size_when_changing_font_size = false

local is_windows = wezterm.target_triple:find("windows") ~= nil
if is_windows then
  config.default_prog = { "pwsh.exe" }
end

return config
