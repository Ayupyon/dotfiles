local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Latte"
config.font = wezterm.font("Maple Mono NF CN")
config.adjust_window_size_when_changing_font_size = false

local is_windows = wezterm.target_triple:find("windows") ~= nil
if is_windows then
	-- use powershell 7 as default shell in windows
	config.default_prog = { "pwsh.exe" }
end

local is_macos = wezterm.target_triple:find("apple") ~= nil
if is_macos then
	-- send <C-_> instead of <C-/> in macos
	config.keys = {
		{
			key = "/",
			mods = "CTRL",
			action = wezterm.action.SendString("\x1f"),
		},
	}
end

return config
