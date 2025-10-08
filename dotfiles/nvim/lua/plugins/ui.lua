return {
    {
        'nvim-mini/mini.statusline',
        version = '*',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('mini.statusline').setup()
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
