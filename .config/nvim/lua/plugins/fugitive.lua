return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  keys = {
    { "<leader>g", "<cmd>Git<cr>", desc = "Fugitive Git status" },
    { "<leader>gc", "<cmd>Git commit<cr>", desc = "Fugitive Git commit" },
    { "<leader>gf", "<cmd>Git pull<cr>", desc = "Fugitive Git pull" },
    { "<leader>gp", "<cmd>Git push<cr>", desc = "Fugitive Git push" },
    {
      "<leader>gd",
      function()
        -- auto-detect current branch
        local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
        vim.cmd("Gvdiffsplit origin/" .. branch)
      end,
      desc = "Diff vs origin/<branch>",
    },
    {
  "<leader>gb",
  function()
    -- Check if we're in a git repository
    if vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true") == nil then
      vim.notify("Not in a git repository", vim.log.levels.ERROR)
      return
    end
    
    -- Get all branches
    local branches_raw = vim.fn.system("git branch -a --no-color 2>/dev/null")
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to get git branches", vim.log.levels.ERROR)
      return
    end
    
    -- Process branches
    local branches = {}
    for line in branches_raw:gmatch("[^\r\n]+") do
      local branch = line:gsub("^[* ]+", ""):gsub("^remotes/[^/]+/", "")
      if branch ~= "" and not branch:match("HEAD") then
        table.insert(branches, branch)
      end
    end
    
    if #branches == 0 then
      vim.notify("No branches found", vim.log.levels.WARN)
      return
    end
    
    -- Use vim.ui.select for branch selection
    vim.ui.select(branches, {
      prompt = "Select branch to diff against: ",
      format_item = function(item) return item end,
    }, function(selected)
      if not selected then return end
      
      -- Use pcall to handle potential errors
      local success, err = pcall(function()
        vim.cmd("Gvdiffsplit " .. vim.fn.shellescape(selected))
      end)
      
      if not success then
        vim.notify("Error opening diff: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end,
  desc = "Diff vs selected branch",
}
    
  },
}

