return {
    {
        -- May be worth considering nvim-mini/mini.statusline. It seems to load a BIT
        -- quicker, and is pretty clean, but could use some configuration. As far as content
        -- is concerned, the defaults for each option have trade-offs, but I'm more
        -- accustomed to the defaults provided by lualine.
        'nvim-lualine/lualine.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('lualine').setup({})
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
            },
            'nvim-telescope/telescope-ui-select.nvim',
            {
                'nvim-tree/nvim-web-devicons',
                opts = {},
            },
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<C-p>', builtin.find_files, {})
            vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
            vim.keymap.set('n', '<C-s>', builtin.lsp_document_symbols, {})
            vim.keymap.set('n', '<leader><Tab>', builtin.buffers, {})

            require('telescope').setup({
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown({})
                    },
                },
            })

            require('telescope').load_extension('ui-select')
        end,
    },
}
