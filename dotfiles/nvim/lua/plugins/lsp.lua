return {
    {
        'mason-org/mason.nvim',
        opts = {},
    },
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            ensure_installed = {
                'ansiblels',
                'eslint',
                'lua_ls',
                'marksman',
                'ts_ls',
            },
        },
        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
        },
    },
    {
        'neovim/nvim-lspconfig',
    },
}
