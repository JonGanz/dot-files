return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup({
                flavour = 'mocha',
                transparent_background = true,
                no_italic = true,
            })
            vim.cmd.colorscheme 'catppuccin-mocha'
        end
    },
    {
        'eddyekofo94/gruvbox-flat.nvim',
        -- enabled = true,
        config = function()
            vim.g.gruvbox_transparent = true
            -- vim.cmd([[colorscheme gruvbox-flat]])
        end,
    },
    {
        'sainnhe/everforest',
        config = function()
            -- vim.cmd.colorscheme 'everforest'
        end
    },
}
