local wezterm = require('wezterm')
local config = wezterm.config_builder()

local font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'Fira Code',
    'Noto Color Emoji',
})

local keybindings = {
    -- Pane Management doesn't need to be a pain
    {
        key = 'Enter',
        mods = 'ALT',
        action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },
    {
        key = 'Enter',
        mods = 'SHIFT|ALT',
        action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },
    {
        key = 'n',
        mods = 'ALT',
        action = wezterm.action.SpawnTab('CurrentPaneDomain'),
    },

    -- Pane Navigation
    {
        key = 'LeftArrow',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection('Left'),
    },
    {
        key = 'RightArrow',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection('Right'),
    },
    {
        key = 'UpArrow',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection('Up'),
    },
    {
        key = 'DownArrow',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection('Down'),
    },

    -- Pane Sizing
    {
        key = 'LeftArrow',
        mods = 'SHIFT|ALT',
        action = wezterm.action.AdjustPaneSize({ 'Left', 5 }),
    },
    {
        key = 'RightArrow',
        mods = 'SHIFT|ALT',
        action = wezterm.action.AdjustPaneSize({ 'Right', 5 }),
    },
    {
        key = 'DownArrow',
        mods = 'SHIFT|ALT',
        action = wezterm.action.AdjustPaneSize({ 'Down', 3 }),
    },
    {
        key = 'UpArrow',
        mods = 'SHIFT|ALT',
        action = wezterm.action.AdjustPaneSize({ 'Up', 3 }),
    },

    -- Pane Scrolling
    {
        key = 'PageUp',
        mods = 'ALT',
        action = wezterm.action.ScrollByLine(-10),
    },
    {
        key = 'PageDown',
        mods = 'ALT',
        action = wezterm.action.ScrollByLine(10),
    },
    {
        key = 'PageUp',
        mods = 'ALT|SHIFT',
        action = wezterm.action.ScrollByPage(-1),
    },
    {
        key = 'PageDown',
        mods = 'ALT|SHIFT',
        action = wezterm.action.ScrollByPage(1),
    },
}

local window_padding = {
    bottom = 0,
    left = 0,
    right = 0,
    top = 0,
}

config.color_scheme = 'Gruvbox Dark (Gogh)'
config.enable_tab_bar = true
config.font = font
config.font_size = 16
config.hide_tab_bar_if_only_one_tab = false -- Undo this, back to true sir!
config.keys = keybindings
config.line_height = 1.1
config.scrollback_lines = 5000
config.use_fancy_tab_bar = false
config.window_decorations = 'RESIZE'
config.window_padding = window_padding

return config
