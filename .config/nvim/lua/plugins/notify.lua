return {
  "rcarriga/nvim-notify",
  opts = function(_, opts)
    opts.background_colour = "#000000"
    opts.timeout = 2000 -- ⏱ default: 2s for all notifications
    return opts
  end,
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify -- replace default notify
  end,
}

