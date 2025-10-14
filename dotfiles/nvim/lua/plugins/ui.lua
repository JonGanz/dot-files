return {
    {
        'kdheepak/lazygit.nvim',
        cmd = {
            'LazyGit',
            'LazyGitConfig',
            'LazyGitCurrentFile',
            'LazyGitFilter',
            'LazyGitFilterCurrentFile',
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        keys = {
            { '<leader>lg', '<Cmd>LazyGit<CR>', mode = 'n', desc = 'Open LazyGit' },
        },
    },
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
            require('lualine').setup({
                options = {
                    theme = 'auto',
                    section_separators = '',
                    component_separators = '',
                },
                sections = {
                    lualine_a = {
                        {
                            'mode',
                            fmt = function(str)
                                local mode_map = {
                                    ['NORMAL'] = 'N',
                                    ['INSERT'] = 'I',
                                    ['VISUAL'] = 'V',
                                    ['V-LINE'] = 'VL',
                                    ['V-BLOCK'] = 'VB',
                                    ['SELECT'] = 'S',
                                    ['COMMAND'] = 'C',
                                    ['REPLACE'] = 'R',
                                    ['TERMINAL'] = 'T',
                                }
                                return mode_map[str] or str:sub(1, 1)
                            end,
                        },
                    },
                    lualine_c = {
                        {
                            function()
                                local filepath = vim.fn.expand('%:~:.')
                                if filepath == '' then
                                    return '[No Name]'
                                end
                                local filename = vim.fn.fnamemodify(filepath, ':t')
                                local dir = vim.fn.fnamemodify(filepath, ':h')
                                if dir == '.' then
                                    return filename
                                else
                                    return string.format('%%#LualineDim#%s/%%#LualineNormal#%s', dir, filename)
                                end
                            end,
                            color = {
                                gui = 'bold',
                            },
                        },
                    },
                    lualine_y = {
                        {
                            function()
                                local current_line = vim.fn.line('.')
                                local total_lines = vim.fn.line('$')
                                return string.format('%d|%d', current_line, total_lines)
                            end,
                        },
                    },
                    lualine_z = {
                        {
                            function()
                                local current_col = vim.fn.col('.')
                                return string.format('%d', current_col)
                            end,
                        },
                    },
                },
            })
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
            vim.keymap.set('n', '<leader>gr', builtin.lsp_references, {})
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
        'nvim-treesitter/nvim-treesitter-context',
        event = { 'BufReadPre', 'BufNewFile' },
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
