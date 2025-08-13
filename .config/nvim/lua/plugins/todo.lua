return {
  "folke/todo-comments.nvim",
  event = "VimEnter",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("todo-comments").setup {}
  end
}
