return {
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        opts = {
            dim = {},
            -- indent = { enabled = true },
            -- notifier = { enabled = true },
            picker = { enabled = true, completion = false },
        },
        keys = {
            {
                '<C-p>',
                function()
                    Snacks.picker.smart({
                        completion = false,
                        exclude = { 'node_modules' },
                    })
                end,
                desc = 'Smart Find Files'
            },

            {
                '<C-f>',
                function()
                    Snacks.picker.grep({
                        exclude = {
                            'node_modules',
                            'package-lock.json',
                            live = true
                        },
                        live = true,
                    })
                end,
                desc = 'Grep'
            },

            { '<C-s>', function() Snacks.picker.lsp_symbols() end, desc = 'Symbols' },
        },
    },
}
