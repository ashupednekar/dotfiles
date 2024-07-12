return {
    'pocco81/true-zen.nvim',
    opts = {
      integrations = {
        tmux = true,
      },
    },
    config = function(_plugin, opts)
      require('true-zen').setup(opts)
    end,
    keys = {
      {
        '<leader>zn',
        '<cmd>TZNarrow<cr>',
        mode = 'n',
        desc = 'Narrow focused',
        noremap = true,
      },
      {
        '<leader>zn',
        "<cmd>'<,'>TZNarrow<cr>",
        mode = 'v',
        desc = 'Ranged narrow focused',
        noremap = true,
      },
      {
        '<leader>zf',
        '<cmd>TZFocus<cr>',
        mode = 'n',
        desc = 'Focued mode',
        noremap = true,
      },
      {
        '<leader>zm',
        '<cmd>TZMinimalist<cr>',
        mode = 'n',
        desc = 'Minimalist mode',
        noremap = true,
      },
      {
        '<leader>za',
        '<cmd>TZAtaraxis<cr>',
        mode = 'n',
        desc = 'Ataraxis mode',
        noremap = true,
      },
    },
  }
 
