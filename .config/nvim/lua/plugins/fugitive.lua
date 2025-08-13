return {
    "tpope/vim-fugitive",
    cmd = { "G", "Git" },  -- lazy-load on Git commands
    config = function()
        vim.api.nvim_set_keymap('n', '<leader>gs', ':G<CR>', { noremap = true, silent = true })
    end,
},
