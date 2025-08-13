-- nvim v0.8.0
return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "LazyGit - Log/Filter" },
    { "<leader>gL", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit - Log Current File" },
  }
}
