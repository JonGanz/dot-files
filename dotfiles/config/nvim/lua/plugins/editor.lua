return {
    {
        'johmsalas/text-case.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim', -- ui.lua
        },
        config = function()
            require('textcase').setup({
                prefix = '<leader>w',
                enabled_methods = {
                    'to_camel_case', -- c
                    'to_constant_case', -- n
                    'to_dash_case', -- d
                    'to_lower_case', -- l
                    'to_pascal_case', -- p
                    'to_snake_case', -- s
                    'to_upper_case', -- u
                },
            })
            require('telescope').load_extension('textcase')
        end,
        keys = {
            '<leader>w',
            {
                '<leader>w.',
                '<Cmd>TextCaseOpenTelescope<CR>',
                mode = { 'n', 'x' },
                desc = 'Change case',
            },
        },
    },
    {
        'nvim-mini/mini.comment',
        version = '*',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('mini.comment').setup()
        end,
    },
    {
        'nvim-mini/mini.surround',
        version = '*',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('mini.surround').setup()
        end,
    },
}
