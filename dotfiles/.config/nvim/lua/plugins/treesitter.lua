return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'bash',
                    'c',
                    'c_sharp',
                    'comment',
                    'cpp',
                    'css',
                    'dockerfile',
                    'html',
                    'javascript',
                    'json',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'scss',
                    'sql',
                    'typescript',
                    'vue',
                    'yaml',
                },
                highlight = {
                    enable = true,
                    disable = function(_, buf)
                        local max_filesize = 1024 * 1024 -- 1MB
                        local ok, stats =
                            pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                },
                indent = { enable = true },
            })
        end,
    },
}
