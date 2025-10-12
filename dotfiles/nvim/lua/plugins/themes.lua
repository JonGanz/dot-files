return {
    {
        'sainnhe/gruvbox-material',
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_background = 'hard'
            vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_transparent_background = 2
            vim.g.gruvbox_material_ui_contrast = 'high'
            vim.cmd.colorscheme 'gruvbox-material'

            local config = vim.fn['gruvbox_material#get_configuration']()
            local palette = vim.fn['gruvbox_material#get_palette'](config.background, config.foreground, config.colors_override)

            -- Telescope overrides.
            vim.cmd.highlight 'link TelescopeBorder Yellow'

            -- nvim-cmp overrides.
            vim.api.nvim_set_hl(0, 'CmpBorder', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'CmpSelection', { bg = palette.bg0[1] })

            -- Lualine overrides
            vim.api.nvim_set_hl(0, 'LualineDim', {
                fg = palette.bg5[1]
            })
        end,
    },
}
