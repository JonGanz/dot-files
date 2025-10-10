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
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                }, {
                    { name = 'buffer', keyword_length = 3 },
                }),
            })
        end,
    },
    {
        'mason-org/mason-lspconfig.nvim',
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
                'yamlls',
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
    {
        'nvimtools/none-ls.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            local null_ls = require('null-ls')
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
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
