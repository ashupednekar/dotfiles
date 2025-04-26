-- disable mouse
vim.o.mouse = ""

-- disable arrow keys in normal, insert, and visual modes
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<left>', '<nop>', opts)
vim.keymap.set('n', '<right>', '<nop>', opts)
vim.keymap.set('n', '<up>', '<nop>', opts)
vim.keymap.set('n', '<down>', '<nop>', opts)
vim.keymap.set('i', '<left>', '<nop>', opts)
vim.keymap.set('i', '<right>', '<nop>', opts)
vim.keymap.set('i', '<up>', '<nop>', opts)
vim.keymap.set('i', '<down>', '<nop>', opts)
vim.keymap.set('v', '<left>', '<nop>', opts)
vim.keymap.set('v', '<right>', '<nop>', opts)
vim.keymap.set('v', '<up>', '<nop>', opts)
vim.keymap.set('v', '<down>', '<nop>', opts)


--telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.find_files, {})
vim.keymap.set('n', '<leader>/', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})

--tab
-- set tab spacing to 4 spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true


--split
vim.api.nvim_set_keymap('n', '<leader>|', ':vsplit<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>_', ':split<cr>', { noremap = true, silent = true })

--resize
vim.api.nvim_set_keymap('n', '<c-j>', ':resize +2<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-k>', ':resize -2<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-h>', ':vertical resize -2<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-l>', ':vertical resize +2<cr>', { noremap = true, silent = true })

--oil
vim.keymap.set('n', '<leader>e', '<cr>:Oil<cr>', { noremap = true, silent = true })

--yank
vim.opt.clipboard = "unnamedplus"
-- remap yank and paste to use the clipboard by default
vim.keymap.set({'n', 'v'}, 'y', '"+y')
vim.keymap.set('n', 'y', '"+y')
vim.keymap.set({'n', 'v'}, 'p', '"+p')
vim.keymap.set({'n', 'v'}, 'P', '"+P')
