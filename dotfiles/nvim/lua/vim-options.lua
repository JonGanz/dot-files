vim.g.mapleader = ' '

vim.cmd('set colorcolumn=90')
vim.cmd('set expandtab')
vim.cmd('set number')
vim.cmd('set relativenumber')
vim.cmd('set shiftwidth=4')
vim.cmd('set softtabstop=4')
vim.cmd('set tabstop=4')

-- Keep things centered vertically.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")

-- Paste over something highlighted without losing the thing you yanked.
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Yank to clipboard.
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

-- Something is preventing <CR> from opening the file in the quickfix list.
-- This prevents that from happening.
vim.cmd('autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>')

