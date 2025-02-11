return {
    {
        'johmsalas/text-case.nvim',
        depedencies = { 'nvim-telescope/telescope.nvim' },
        config = function()
            local textcase = require('textcase');
            textcase.setup({
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
        end,
    },
}
