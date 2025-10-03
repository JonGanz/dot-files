return {
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
