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
                    'lua_ls',
                    'marksman',
                    'intelephense',
                    'tsserver',
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
            lspconfig.lua_ls.setup({})
            lspconfig.marksman.setup({})
            lspconfig.intelephense.setup({})
            lspconfig.tsserver.setup({})
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
