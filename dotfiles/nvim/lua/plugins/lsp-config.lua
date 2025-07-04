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
                    'gopls',
                    'intelephense',
                    'lua_ls',
                    'marksman',
                    'omnisharp',
                    'powershell_es',
                    'sqlls',
                    'ts_ls',
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

            -- Supposedly could use $MASON/packages, but either that doesn't work with
            -- nvim 0.10.4 or it's not functioning correctly with the WSL setup.
            local mason_package_dir = vim.fn.expand('~/.local/share/nvim/mason/packages')

            lspconfig.ansiblels.setup({})
            lspconfig.clangd.setup({})
            lspconfig.eslint.setup({})
            lspconfig.gopls.setup({})
            lspconfig.intelephense.setup({})
            lspconfig.lua_ls.setup({})
            lspconfig.marksman.setup({})
            lspconfig.omnisharp.setup({
                cmd = { "dotnet", vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
            })
            lspconfig.powershell_es.setup({})
            lspconfig.sqlls.setup({})
            lspconfig.ts_ls.setup({
                init_options = {
                    plugins = {
                        {
                            name = '@vue/typescript-plugin',
                            location = mason_package_dir .. '/vue-language-server/node_modules/@vue/language-server',
                            languages = { 'vue' },
                        },
                    },
                },
                filetypes = {
                    'typescript',
                    'javascript',
                    'javascriptreact',
                    'typescriptreact',
                    'vue',
                },
            })
            lspconfig.volar.setup({
                init_options = {
                    typescript = {
                        tsdk = mason_package_dir .. '/vue-language-server/node_modules/typescript/lib'
                    },
                },
            })
            lspconfig.yamlls.setup({})

            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
        end
    },
}
