return {
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end,
    },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'ansiblels',
                    'clangd',
                    'eslint',
                    'lua_ls',
                    'marksman',
                    'intelephense',
                    'ts_ls',
                    'powershell_es',
                    'sqlls',
                    'volar',
                    'yamlls'
                },
            })
        end
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.ansiblels.setup({})
            lspconfig.clangd.setup({})
            lspconfig.eslint.setup({})
            lspconfig.lua_ls.setup({})
            lspconfig.marksman.setup({})
            lspconfig.intelephense.setup({})
            lspconfig.ts_ls.setup({})
            lspconfig.powershell_es.setup({})
            lspconfig.sqlls.setup({})
            lspconfig.volar.setup({})
            lspconfig.yamlls.setup({})

            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
        end
    },
}
