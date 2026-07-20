local M = {}
local did_setup = false

local function open_pr_picker()
  Snacks.picker.gh_pr()
end

local function open_pr_buffer(repo, number)
  require("snacks.gh.buf").setup()
  vim.cmd.edit(vim.fn.fnameescape(("gh://%s/pr/%s"):format(repo, number)))
end

local function open_pr_actions(repo, pr)
  local number = tonumber(pr.number) or tonumber(pr)
  local uri = ("gh://%s/pr/%s"):format(repo, number)
  local item = {
    type = "pr",
    repo = repo,
    number = number,
    uri = uri,
    file = uri,
    state = pr.state and pr.state:lower() or "open",
    title = pr.title,
    url = pr.url,
    headRefName = pr.headRefName,
    headRefOid = pr.headRefOid,
    item = {
      labels = pr.labels or {},
    },
  }
  require("snacks.gh.actions").actions.gh_actions.action(item, { items = { item } })
end

local function clamp_diff_preview_cursor(buf)
  if vim.b[buf].snacks_gh_diff_cursor_clamp then
    return
  end
  vim.b[buf].snacks_gh_diff_cursor_clamp = true

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      local win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_buf(win) ~= buf then
        return
      end

      local cursor = vim.api.nvim_win_get_cursor(win)
      local line = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1] or ""
      local first = line:find("%S")
      if first and cursor[2] < first - 1 then
        vim.api.nvim_win_set_cursor(win, { cursor[1], first - 1 })
      end
    end,
  })
end

local function gh_diff_opts(repo, number)
  return {
    show_delay = 0,
    repo = repo,
    pr = number,
    preview = function(ctx)
      local buf = ctx.preview:scratch()
      ctx.preview.win:map()
      require("snacks.picker.util.diff").render(buf, vim.api.nvim_create_namespace("snacks_gh_diff_preview"), ctx.item.diff, {
        annotations = ctx.item.annotations or ctx.picker.opts.annotations,
        hunk_header = false,
      })
      Snacks.util.wo(ctx.win, ctx.picker.opts.previewers.diff.wo or {})
      clamp_diff_preview_cursor(buf)

      local item = ctx.item.gh_item
      if item then
        vim.b[ctx.buf].snacks_gh = {
          repo = item.repo,
          type = item.type,
          number = item.number,
        }
      end
    end,
    layout = {
      layout = {
        backdrop = false,
        width = 0.95,
        height = 0.9,
        min_height = 30,
        box = "vertical",
        border = true,
        title = "{title} {live} {flags}",
        title_pos = "center",
        {
          win = "input",
          height = 1,
          border = "bottom",
        },
        {
          win = "list",
          height = 0.2,
          border = "none",
        },
        {
          win = "preview",
          title = "{preview}",
          height = 0.8,
          border = "top",
        },
      },
    },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "preview_full", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["<CR>"] = "preview_full",
        },
      },
      preview = {
        keys = {
          ["]f"] = "list_down",
          ["[f"] = "list_up",
        },
      },
    },
  }
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
  if branch == "" or branch == "main" or branch == "master" then
    return open_pr_picker()
  end

  local cmd = { "gh", "pr", "view" }
  cmd[#cmd + 1] = branch
  vim.list_extend(cmd, { "--json", repo and "number,state,title,url,headRefName,headRefOid,labels" or "url" })
  if repo then
    vim.list_extend(cmd, { "--repo", repo })
  end

  local done = false
  local timer = assert((vim.uv or vim.loop).new_timer())
  local proc

  local function finish_with_picker()
    if done then
      return
    end
    done = true
    timer:stop()
    timer:close()
    if proc then
      pcall(function()
        proc:kill("sigterm")
      end)
    end
    vim.schedule(open_pr_picker)
  end

  timer:start(5000, 0, finish_with_picker)

  proc = vim.system(cmd, { cwd = vim.fn.getcwd(), text = true }, function(result)
    if done then
      return
    end
    done = true
    timer:stop()
    timer:close()
    vim.schedule(function()
      if result.code ~= 0 then
        return open_pr_picker()
      end

      local pr
      if repo then
        local ok, decoded = pcall(vim.json.decode, result.stdout)
        if ok then
          pr = decoded
        end
      end

      local number = pr and pr.number or nil
      if not number then
        repo, number = result.stdout:match("github%.com/([^/]+/[^/]+)/pull/(%d+)")
        pr = { number = tonumber(number), state = "OPEN" }
      end

      if not repo or not number then
        return open_pr_picker()
      end

      open_pr_buffer(repo, number)
      open_pr_actions(repo, pr)
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
          Snacks.picker.gh_diff(gh_diff_opts(item.repo, item.number))
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

  local function open_worktree(number)
    number = number and tostring(number):match("%d+")
    if not number then
      return notify("Could not determine PR number", vim.log.levels.ERROR)
    end

    notify("Opening PR #" .. number)
    vim.system({ "workmux", "add", "--open-if-exists", "--pr", number }, { cwd = vim.fn.getcwd(), text = true }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          notify("Opened PR #" .. number)
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

      open_worktree(item.number)
    end,
  }
end

local function configure_gh_diff_layout()
  local actions = require("snacks.gh.actions").actions
  local gh_diff = actions.gh_diff
  local gh_open = actions.gh_open
  gh_diff.priority = 300
  gh_open.action = function(item)
    if not item then
      return
    end

    open_pr_buffer(item.repo, item.number)
  end

  gh_diff.action = function(item)
    if not item then
      return
    end

    Snacks.picker.gh_diff(gh_diff_opts(item.repo, item.number))
  end
end

function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  require("snacks").setup(opts)
  require("snacks.gh").config().wo.foldlevel = 99
  set_keymaps()
  configure_gh_diff_layout()
  configure_workmux_checkout()
end

M.setup()

return M
