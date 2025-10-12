return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                window = {
                    completion = cmp.config.window.bordered({
                        winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSelection,Search:None',
                    }),
                    documentation = cmp.config.window.bordered({
                        winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder',
                    }),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                }),
                sources = cmp.config.sources(
                    { { name = 'nvim_lsp' } },
                    { { name = 'buffer', keyword_length = 3 } }
                ),
            })
        end,
    },
    {
        'github/copilot.vim',
    },
    {
        'mason-org/mason-lspconfig.nvim',
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
        opts = {
            ensure_installed = {
                'ansiblels',
                'clangd',
                'eslint',
                'gopls',
                'lua_ls',
                'marksman',
                'omnisharp',
                'sqlls',
                'ts_ls',
                'vue_ls',
                'yamlls',
            },
        },
        config = function(_, opts)
            require('mason-lspconfig').setup(opts)

            -- Setup the Vue language support.
            -- https://github.com/vuejs/language-tools/wiki/Neovim
            local vue_language_server_path = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server'
            local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
            local vue_plugin = {
                name = '@vue/typescript-plugin',
                location = vue_language_server_path,
                languages = { 'vue' },
                configNamespace = 'typescript',
            }

            local ts_ls_config = {
                init_options = {
                    plugins = {
                        vue_plugin,
                    },
                },
                filetypes = tsserver_filetypes,
            }

            local vue_ls_config = {}

            vim.lsp.config('vue_ls', vue_ls_config)
            vim.lsp.config('ts_ls', ts_ls_config)
            vim.lsp.enable({'ts_ls', 'vue_ls'})

            -- Enable in-line diagnostics.
            vim.diagnostic.config({
                signs = false,
                virtual_text = true,
            })
        end,
    },
    {
        'nvimtools/none-ls.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            local null_ls = require('null-ls')
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua.with({
                        filetypes = { 'lua' },
                    }),
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { 'html', 'css', 'json', 'markdown', 'scss' },
                    }),
                },
            })
        end,
        keys = {
            { '<leader>ff', vim.lsp.buf.format, mode = 'n', desc = 'Format file' },
        },
    },
}
