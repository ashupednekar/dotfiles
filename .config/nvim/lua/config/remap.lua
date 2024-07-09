--telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.find_files, {})
vim.keymap.set('n', '<leader>/', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})

--neotree
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true })
