local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Maple Mono")
config.adjust_window_size_when_changing_font_size = false
config.debug_key_events = true
config.keys = {}

local is_windows = wezterm.target_triple:find("windows") ~= nil
if is_windows then
  -- use powershell 7 as default shell in windows
  config.default_prog = { "pwsh.exe" }
end

-- tmux-style leader key (Ctrl+D); press Ctrl+D twice to send a real EOF
config.disable_default_key_bindings = true
config.leader = { key = "d", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- send real Ctrl+D (EOF) when pressing the leader twice
  {
    key = "d",
    mods = "LEADER|CTRL",
    action = wezterm.action.SendKey({ key = "d", mods = "CTRL" }),
  },

  -- font size (direct, non-leader)
  { key = "+", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
  { key = "=", mods = "CTRL",       action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CTRL",       action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CTRL",       action = wezterm.action.ResetFontSize },

  -- copy / paste / search
  { key = "c", mods = "SUPER",      action = wezterm.action.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER",      action = wezterm.action.PasteFrom("Clipboard") },
  { key = "v", mods = "CTRL",       action = wezterm.action.PasteFrom("Clipboard") },
  { key = "f", mods = "CTRL",       action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
  { key = "f", mods = "SUPER",      action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
  -- Ctrl+C: copy if there's a selection, otherwise send ^C (SIGINT)
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
      else
        window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
      end
    end),
  },

  -- tabs
  { key = "c", mods = "LEADER",       action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER",       action = wezterm.action.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER",       action = wezterm.action.ActivateTabRelative(-1) },
  -- wezterm tabs are 1-indexed on the tab bar, so Leader+N selects tab N
  { key = "1", mods = "LEADER",       action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "LEADER",       action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "LEADER",       action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "LEADER",       action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "LEADER",       action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "LEADER",       action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "LEADER",       action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "LEADER",       action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "LEADER",       action = wezterm.action.ActivateTab(8) },
  { key = "0", mods = "LEADER",       action = wezterm.action.ActivateTab(9) },
  { key = "&", mods = "LEADER|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
  {
    key = ",",
    mods = "LEADER",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- pane splitting: % = left/right, " = top/bottom (tmux semantics)
  { key = "%",          mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = '"',          mods = "LEADER|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- pane navigation (vim-style + arrow keys)
  { key = "h",          mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j",          mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k",          mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l",          mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "LeftArrow",  mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "DownArrow",  mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "UpArrow",    mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "o",          mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Next") },

  -- pane management
  { key = "x",          mods = "LEADER",       action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  { key = "z",          mods = "LEADER",       action = wezterm.action.TogglePaneZoomState },

  -- copy mode / paste / tab navigator
  { key = "[",          mods = "LEADER",       action = wezterm.action.ActivateCopyMode },
  { key = "]",          mods = "LEADER",       action = wezterm.action.PasteFrom("Clipboard") },
  { key = "s",          mods = "LEADER",       action = wezterm.action.ShowTabNavigator },
}

-- macOS: send <C-_> instead of <C-/>
local is_macos = wezterm.target_triple:find("apple") ~= nil
if is_macos then
  -- send <C-_> instead of <C-/> in macos
  table.insert(config.keys,
    {
      key = "/",
      mods = "CTRL",
      action = wezterm.action.SendString("\x1f"),
    }
  )
end

return config
