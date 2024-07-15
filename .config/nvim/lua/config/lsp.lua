local lspconfig = require("lspconfig")
lspconfig.gopls.setup({
})


lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {},
  },
}
