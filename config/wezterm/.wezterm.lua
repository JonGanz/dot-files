local wezterm = require('wezterm')
local config = wezterm.config_builder()

local font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'Fira Code',
    'Noto Color Emoji',
})

local keybindings = {
    {
        key = 'F11',
        action = wezterm.action.ToggleFullScreen,
    },
}

local window_padding = {
    bottom = 0,
    left = 0,
    right = 0,
    top = 0,
}

config.audible_bell = 'Disabled'
config.color_scheme = 'Gruvbox Material (Gogh)'
config.enable_tab_bar = false
config.enable_wayland = false
config.font = font
config.font_size = 12
config.hide_tab_bar_if_only_one_tab = true
config.keys = keybindings
config.scrollback_lines = 5000
config.use_fancy_tab_bar = false
config.window_decorations = 'RESIZE'
config.window_padding = window_padding

return config
