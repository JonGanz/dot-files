return {
    {
        'hrsh7th/cmp-nvim-lsp',
    },
    {
        'github/copilot.vim',
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
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

                    -- Literally never used these...
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4), -- this may be a problem.. possible conflict
                    ['<C-space>'] = cmp.mapping.complete(), -- this is an awkward reach...
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                }, {
                    { name = 'buffer', keyword_length = 3 },
                }),
            })
        end,
    },
}
