return {
    {
        'ribru17/bamboo.nvim',
        priority = 1000,
        config = function()
            require('bamboo').setup({
                lualine = {
                    transparent = true,
                },
                style = 'vulgaris',
                transparent = true,
            })
            require('bamboo').load()
        end,
    },
    -- {
    --     'catppuccin/nvim',
    --     name = 'catppuccin',
    --     config = function()
    --         require('catppuccin').setup({
    --             flavour = 'mocha',
    --             transparent_background = true,
    --             no_italic = true,
    --             integrations = {
    --                 harpoon = true,
    --                 indent_blankline = {
    --                     enabled = true,
    --                 },
    --                 markdown = true,
    --                 mini = {
    --                     enabled = true,
    --                 },
    --                 treesitter = true,
    --             },
    --         })
    --         vim.cmd.colorscheme 'catppuccin-mocha'
    --     end
    -- },
    -- {
    --     'eddyekofo94/gruvbox-flat.nvim',
    --     -- enabled = true,
    --     config = function()
    --         vim.g.gruvbox_transparent = true
    --         vim.cmd([[colorscheme gruvbox-flat]])
    --     end,
    -- },
    -- {
    --     'sainnhe/everforest',
    --     config = function()
    --         vim.cmd.colorscheme 'everforest'
    --     end
    -- },
    -- {
    --     'rebelot/kanagawa.nvim',
    --     config = function()
    --         require('kanagawa').setup({
    --             transparent = true,
    --         })
    --     end
    -- },
    -- -- This one is really nice, but need to investigate options for transparent background.
    -- { 'jacoborus/tender.vim' },
    -- {
    --     'bluz71/vim-moonfly-colors',
    --     config = function()
    --         vim.g.moonflyTransparent = true
    --     end,
    -- },
}
