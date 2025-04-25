
--telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.find_files, {})
vim.keymap.set('n', '<leader>/', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})

--tab
-- Set tab spacing to 4 spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true


--split
vim.api.nvim_set_keymap('n', '<Leader>|', ':vsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>_', ':split<CR>', { noremap = true, silent = true })

--resize
vim.api.nvim_set_keymap('n', '<C-Up>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Down>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Left>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Right>', ':vertical resize +2<CR>', { noremap = true, silent = true })

--neotree
vim.keymap.set('n', '<leader>e', '<CR>:Oil<CR>', { noremap = true, silent = true })

--yank
vim.opt.clipboard = "unnamedplus"
-- Remap yank and paste to use the clipboard by default
vim.keymap.set({'n', 'v'}, 'y', '"+y')
vim.keymap.set('n', 'Y', '"+Y')
vim.keymap.set({'n', 'v'}, 'p', '"+p')
vim.keymap.set({'n', 'v'}, 'P', '"+P')
