--telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.find_files, {})
vim.keymap.set('n', '<leader>/', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})

--split
vim.api.nvim_set_keymap('n', '<Leader>|', ':vsplit<CR>', { noremap = true, silent = true })

--resize
vim.api.nvim_set_keymap('n', '<C-Up>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Down>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Left>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Right>', ':vertical resize +2<CR>', { noremap = true, silent = true })


--neotree
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true })

--lazy
vim.keymap.set('n', '<leader>L', ':Lazy', { noremap = true, silent = true })

--truezen
local api = vim.api

api.nvim_set_keymap("n", "<leader>zn", ":TZNarrow<CR>", {})
api.nvim_set_keymap("v", "<leader>zn", ":'<,'>TZNarrow<CR>", {})
api.nvim_set_keymap("n", "<leader>zf", ":TZFocus<CR>", {})
api.nvim_set_keymap("n", "<leader>zm", ":TZMinimalist<CR>", {})
api.nvim_set_keymap("n", "<leader>za", ":TZAtaraxis<CR>", {})

