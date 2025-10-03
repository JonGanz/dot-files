return {
    {
        'nvim-mini/mini.statusline',
        version = '*',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('mini.statusline').setup()
        end,
    },
}
