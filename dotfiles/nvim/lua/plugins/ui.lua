return {
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('ibl').setup()
        end,
    },
    {
        -- May be worth considering nvim-mini/mini.statusline. It seems to load a BIT
        -- quicker, and is pretty clean, but could use some configuration. As far as content
        -- is concerned, the defaults for each option have trade-offs, but I'm more
        -- accustomed to the defaults provided by lualine.
        'nvim-lualine/lualine.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('lualine').setup({})
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
            },
            'nvim-telescope/telescope-ui-select.nvim',
            {
                'nvim-tree/nvim-web-devicons',
                opts = {},
            },
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<C-p>', builtin.find_files, {})
            vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
            vim.keymap.set('n', '<C-s>', builtin.lsp_document_symbols, {})
            vim.keymap.set('n', '<leader><Tab>', builtin.buffers, {})

            require('telescope').setup({
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown({})
                    },
                },
            })

            require('telescope').load_extension('ui-select')
        end,
    },
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            local harpoon = require('harpoon')
            harpoon:setup({})
        end,
        keys = {
            { '<leader>a', '<Cmd>lua require("harpoon"):list():add()<CR>', mode = 'n', desc = 'Add to Harpoon' },
            { '<C-j>', '<Cmd>lua require("harpoon"):list():select(1)<CR>', mode = 'n', desc = 'Harpoon file 1' },
            { '<C-k>', '<Cmd>lua require("harpoon"):list():select(2)<CR>', mode = 'n', desc = 'Harpoon file 2' },
            { '<C-l>', '<Cmd>lua require("harpoon"):list():select(3)<CR>', mode = 'n', desc = 'Harpoon file 3' },
            { '<C-m>', '<Cmd>lua require("harpoon"):list():select(4)<CR>', mode = 'n', desc = 'Harpoon file 4' },
            { '<C-e>', '<Cmd>lua require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())<CR>', mode = 'n', desc = 'View Harpoon file list' },
        },
    },
}
