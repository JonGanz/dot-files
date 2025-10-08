return {
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            ensure_installed = {
                'ansiblels',
                'eslint',
                'lua_ls',
                'marksman',
                'ts_ls',
            },
        },
        dependencies = {
            {
                'mason-org/mason.nvim',
                opts = {},
            },
            {
                'neovim/nvim-lspconfig',
                config = function()
                    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, {})
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
                end,
            },
        },
    },
}
