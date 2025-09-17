return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  keys = {
    { "<leader>g", "<cmd>Git<cr>", desc = "Fugitive Git status" },
    { "<leader>gc", "<cmd>Git commit<cr>", desc = "Fugitive Git commit" },
    {
      "<leader>gd",
      function()
        local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
        vim.cmd("Gvdiffsplit origin/" .. branch)
      end,
      desc = "Diff vs origin/<branch>",
    },
    {
      "<leader>gp",
      function()
        local notify = require("notify")

        -- spinner characters
        local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        local spinner_idx = 1
        local notif, timer
        local running = true

        -- start initial notification (store the full record!)
        notif = notify("⠋ Git pull --rebase in progress...", "info", { timeout = false })

        -- update spinner every 120ms
        timer = vim.loop.new_timer()
        timer:start(0, 120, function()
          if not running then
            timer:stop()
            timer:close()
            return
          end
          vim.schedule(function()
            spinner_idx = (spinner_idx % #spinners) + 1
            notif = notify(spinners[spinner_idx] .. " Git pull --rebase && push in progress...", "info", {
              replace = notif,
              hide_from_history = true,
              timeout = false,
            })
          end)
        end)

        -- run pull
        vim.fn.jobstart({ "git", "pull", "--rebase" }, {
          stdout_buffered = true,
          stderr_buffered = true,
          on_exit = function(_, code1, _)
            if code1 == 0 then
              notif = notify("Git push in progress...", "info", { replace = notif, timeout = false })

              vim.fn.jobstart({ "git", "push" }, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_exit = function(_, code2, _)
                  running = false
                  if code2 == 0 then
                    notify("✅ Git pull --rebase && push completed", "info", {
                      replace = notif,
                      timeout = 2000,
                    })
                  else
                    notify("❌ Git push failed", "error", {
                      replace = notif,
                      timeout = 4000,
                    })
                  end
                end,
              })
            else
              running = false
              notify("❌ Git pull --rebase failed", "error", {
                replace = notif,
                timeout = 4000,
              })
            end
          end,
        })
      end,
      desc = "Git pull --rebase && push (async with loader)",
    },
    {
      "<leader>gg",
      function()
        local notify = require("notify")
        -- Stage all changes
        vim.fn.system("git add .")
        -- Check if staging was successful
        if vim.v.shell_error == 0 then
          -- Open commit message pop-up
          vim.cmd("Git commit")
          notify("Staged all changes, opened commit message pop-up", "info", { timeout = 2000 })
        else
          notify("❌ Failed to stage changes", "error", { timeout = 4000 })
        end
      end,
      desc = "Git add all and commit with message pop-up",
    }
  },
}

