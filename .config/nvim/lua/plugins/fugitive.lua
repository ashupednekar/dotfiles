return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  keys = {
    { "<leader>g", "<cmd>Git<cr>", desc = "Fugitive Git status" },
    { "<leader>gw", "<cmd>Git write<cr>", desc = "Fugitive Git status" },
    { "<leader>gc", "<cmd>Git commit<cr>", desc = "Fugitive Git status" },
    { "<leader>gf", "<cmd>Git pull<cr>", desc = "Fugitive Git status" },
    { "<leader>gp", "<cmd>Git push<cr>", desc = "Fugitive Git status" },
  },
}
