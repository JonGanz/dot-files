return {
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<C-p>', builtin.find_files, {})
            vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
            vim.keymap.set('n', '<C-s>', builtin.lsp_document_symbols, {})
            vim.keymap.set('n', '<leader><Tab>', builtin.buffers, {})
        end
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require('telescope').setup({
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown {
                        }
                    }
                },
                defaults = {
                    file_ignore_patterns = {
                        'node_modules',
                        'package%-lock%.json',
                    },
                },
            })
            require('telescope').load_extension('ui-select')
        end
    },
}
