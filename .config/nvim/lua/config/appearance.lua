require("lualine").setup{
  options = {
    theme = 'iceberg_dark',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
  },
  sections = {
    lualine_c = {
      {
        function()
          local filepath = vim.fn.expand('%:p')
          local cwd = vim.fn.getcwd()
          return filepath:gsub(cwd .. '/', '')
        end,
        color = { fg = '#88C0D0' }, -- optional styling
        icon = '📁', -- optional icon
      }
    }
  }
}

require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = true, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers 
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"
vim.opt.termguicolors = true
