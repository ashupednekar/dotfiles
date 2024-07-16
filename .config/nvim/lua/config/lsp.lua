

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()


equire('nvim-autopairs').setup{}

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {"gopls", "rust_analyzer", "pyright"},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})



local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    }
})

