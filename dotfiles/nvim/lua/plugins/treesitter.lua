return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local config = require('nvim-treesitter.configs')
            config.setup({
                ensure_installed = {
                    'bash',
                    'c',
                    'c_sharp',
                    'cpp',
                    'css',
                    'dockerfile',
                    'html',
                    'javascript',
                    'json',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'php',
                    'scss',
                    'sql',
                    'typescript',
                    'yaml',
                },
                highlight = { enabled = true },
                indent = { enabled = true },
            })
        end
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
    },
}
