-- Keep things centered vertically.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "'a", "'azz")
vim.keymap.set("n", "'b", "'bzz")
vim.keymap.set("n", "'c", "'czz")
vim.keymap.set("n", "<C-Down>", "16jzz")
vim.keymap.set("n", "<C-Up>", "16kzz")

-- Paste over something highlighted without losing the thing you yanked.
vim.keymap.set("x", "<leader>p", "\"_dP", { desc = 'Paste & keep yanked text' })

-- Yank to clipboard.
vim.keymap.set({'n', 'v'}, "<leader>y", "\"+y", { desc = 'Yank to Clipboard' })

-- Quickly exit insert mode without stressing my poor little pinky.
vim.keymap.set("i", "jj", "<Esc>", { noremap = false })

-- Move through screen lines rather than actual lines (when line wrapping is on).
vim.keymap.set({'n', 'x'}, 'j', function() return vim.v.count == 0 and 'gj' or 'j' end, { expr = true })
vim.keymap.set({'n', 'x'}, '<Down>', function() return vim.v.count == 0 and 'gj' or 'j' end, { expr = true })
vim.keymap.set({'n', 'x'}, 'k', function() return vim.v.count == 0 and 'gk' or 'k' end, { expr = true })
vim.keymap.set({'n', 'x'}, '<Up>', function() return vim.v.count == 0 and 'gk' or 'k' end, { expr = true })

-- Quickly move a line up/down.
vim.keymap.set('n', '<A-j>', '<cmd>execute \'move .+\' . v:count1<CR>==')
vim.keymap.set('n', '<A-k>', '<cmd>execute \'move .-\' . (v:count1 + 1)<CR>==')

-- Clear the highlighted text.
vim.keymap.set('n', '<leader><Esc>', '<cmd>noh<CR>', { desc = 'Clear highlights' })

-- Quit.
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit All' })

-- Something is preventing <CR> from opening the file in the quickfix list. This prevents
-- that from happening.
vim.cmd('autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>')

