local M = {}
local did_setup = false

local function open_pr_picker()
  Snacks.picker.gh_pr()
end

local function github_repo()
  local url = vim.fn.system({ "git", "remote", "get-url", "origin" }):gsub("%s+$", "")
  local repo = url:match("^[^@]+@[^:]+:(.+)$") or url:match("^https?://[^/]+/(.+)$")
  return repo and repo:gsub("%.git$", "")
end

local function open_current_pr_or_picker()
  if vim.fn.executable("gh") ~= 1 then
    return open_pr_picker()
  end

  local repo = github_repo()
  local branch = vim.fn.system({ "git", "branch", "--show-current" }):gsub("%s+$", "")
  local cmd = { "gh", "pr", "view" }
  if branch ~= "" then
    cmd[#cmd + 1] = branch
  end
  vim.list_extend(cmd, { "--json", repo and "number" or "url", "--jq", repo and ".number" or ".url" })
  if repo then
    vim.list_extend(cmd, { "--repo", repo })
  end

  vim.system(cmd, { cwd = vim.fn.getcwd(), text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        return open_pr_picker()
      end

      local number = repo and result.stdout:match("%d+") or nil
      if not number then
        repo, number = result.stdout:match("github%.com/([^/]+/[^/]+)/pull/(%d+)")
      end

      if not repo or not number then
        return open_pr_picker()
      end

      Snacks.picker.gh_diff({ show_delay = 0, repo = repo, pr = tonumber(number) })
    end)
  end)
end

local function picker_preview_full(picker)
  local layout = picker.layout
  if not layout then
    return
  end
  local preview = layout.wins and layout.wins.preview
  if not preview or not preview:valid() then
    return
  end

  picker:focus("preview", { show = true })
end

local function picker_restore_list(picker)
  if not picker.layout then
    return
  end

  picker:focus("list", { show = true })
end

local opts = {
  gh = {
    keys = {
      diff = {
        "d",
        function(item)
          Snacks.picker.gh_diff({ show_delay = 0, repo = item.repo, pr = item.number })
        end,
        desc = "View diff",
      },
    },
  },
  picker = {
    enabled = true,
    focus = "list",
    actions = {
      preview_full = picker_preview_full,
      restore_list = picker_restore_list,
    },
    win = {
      input = {
        keys = {
          ["<Esc>"] = { "focus_list", mode = { "n", "i" } },
          ["<a-w>"] = { "preview_full", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["<a-w>"] = "preview_full",
        },
      },
      preview = {
        keys = {
          ["<Esc>"] = "restore_list",
          ["<a-w>"] = "preview_full",
        },
      },
    },
  },
  scratch = { enabled = true },
}

local function set_keymaps()
  vim.keymap.set("n", "<leader>pr", open_current_pr_or_picker, { desc = "GitHub Pull Request" })
  vim.keymap.set("n", "<leader>pR", function()
    Snacks.picker.gh_pr({ state = "all" })
  end, { desc = "GitHub Pull Requests (all)" })
  vim.keymap.set("n", "<leader>pi", function()
    Snacks.picker.gh_issue()
  end, { desc = "GitHub Issues (open)" })
  vim.keymap.set("n", "<leader>pI", function()
    Snacks.picker.gh_issue({ state = "all" })
  end, { desc = "GitHub Issues (all)" })
end

local function configure_workmux_checkout()
  if not vim.env.TMUX or vim.fn.executable("workmux") ~= 1 then
    return
  end

  local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "GitHub PR Worktree" })
  end

  local function open_worktree(branch)
    branch = branch and branch:match("%S+")
    if not branch then
      return notify("Could not determine PR branch", vim.log.levels.ERROR)
    end

    local ref = "origin/" .. branch
    notify("Opening " .. ref)
    vim.system({ "workmux", "add", "--open-if-exists", ref }, { cwd = vim.fn.getcwd(), text = true }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          notify("Opened " .. ref)
        else
          notify(result.stderr ~= "" and result.stderr or result.stdout, vim.log.levels.ERROR)
        end
      end)
    end)
  end

  require("snacks.gh.actions").actions.gh_checkout = {
    desc = "Open PR worktree",
    icon = " ",
    priority = 80,
    title = "Open PR #{number} in workmux",
    type = "pr",
    action = function(item)
      if not item then
        return
      end

      if item.headRefName then
        return open_worktree(item.headRefName)
      end

      local cmd = { "gh", "pr", "view", tostring(item.number), "--json", "headRefName", "--jq", ".headRefName" }
      if item.repo then
        vim.list_extend(cmd, { "--repo", item.repo })
      end

      vim.system(cmd, { cwd = vim.fn.getcwd(), text = true }, function(result)
        vim.schedule(function()
          if result.code == 0 then
            open_worktree(result.stdout)
          else
            notify(result.stderr, vim.log.levels.ERROR)
          end
        end)
      end)
    end,
  }
end

function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  require("snacks").setup(opts)
  require("snacks.gh").config().wo.foldlevel = 99
  set_keymaps()
  configure_workmux_checkout()
end

M.setup()

return M
