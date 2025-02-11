vim.cmd('set expandtab')
vim.cmd('set tabstop=4')
vim.cmd('set softtabstop=4')
vim.cmd('set shiftwidth=4')
vim.cmd('set number')
vim.cmd('set relativenumber')
vim.cmd('set colorcolumn=90')
vim.g.mapleader = ' '

-- Keep things centered vertically.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")

-- paste over something highlighted without losing the thing you yanked
vim.keymap.set("x", "<leader>p", "\"_dP")

-- yank to clipboard?
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

