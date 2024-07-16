require("lualine").setup{
  options = {
    theme = 'iceberg_dark',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
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
