return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 1000,
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next Git hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous Git hunk")

      map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
      map("v", "<leader>hs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage selected hunk")
      map("v", "<leader>hr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset selected hunk")
      map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>hi", gitsigns.preview_hunk_inline, "Preview hunk inline")
      map("n", "<leader>hb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>hd", gitsigns.diffthis, "Diff this")
      map("n", "<leader>hD", function()
        gitsigns.diffthis("~")
      end, "Diff this against previous revision")
      map("n", "<leader>hq", gitsigns.setqflist, "Git hunks to quickfix")
      map("n", "<leader>hQ", function()
        gitsigns.setqflist("all")
      end, "All Git hunks to quickfix")
      map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle Git blame")
      map("n", "<leader>tw", gitsigns.toggle_word_diff, "Toggle Git word diff")
      map({ "o", "x" }, "ih", gitsigns.select_hunk, "Git hunk")
    end,
  },
}
