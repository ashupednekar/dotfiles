-- disable mouse
vim.o.mouse = ""

-- Disable arrow keys in normal, insert, and visual modes
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<Left>', '<Nop>', opts)
vim.keymap.set('n', '<Right>', '<Nop>', opts)
vim.keymap.set('n', '<Up>', '<Nop>', opts)
vim.keymap.set('n', '<Down>', '<Nop>', opts)
vim.keymap.set('v', '<Left>', '<Nop>', opts)
vim.keymap.set('v', '<Right>', '<Nop>', opts)
vim.keymap.set('v', '<Up>', '<Nop>', opts)
vim.keymap.set('v', '<Down>', '<Nop>', opts)


--telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.find_files, {})
vim.keymap.set('n', '<leader>/', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})
telescope.setup({
  defaults = {
    mappings = {
      i = { -- insert mode
        ["<C-h>"] = "which_key", -- optional: shows keymap hints
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-l>"] = "select_default",
      },
      n = { -- normal mode
        ["h"] = "which_key",
        ["j"] = "move_selection_next",
        ["k"] = "move_selection_previous",
        ["l"] = "select_default",
      },
    },
  },
})

--tab
-- Set tab spacing to 4 spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true


--split
vim.api.nvim_set_keymap('n', '<Leader>|', ':vsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>_', ':split<CR>', { noremap = true, silent = true })

--resize
vim.api.nvim_set_keymap('n', '<C-j>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':vertical resize +2<CR>', { noremap = true, silent = true })

--neotree
vim.keymap.set('n', '<leader>e', '<CR>:Oil<CR>', { noremap = true, silent = true })

--yank
vim.opt.clipboard = "unnamedplus"
-- Remap yank and paste to use the clipboard by default
vim.keymap.set({'n', 'v'}, 'y', '"+y')
vim.keymap.set('n', 'Y', '"+Y')
vim.keymap.set({'n', 'v'}, 'p', '"+p')
vim.keymap.set({'n', 'v'}, 'P', '"+P')
