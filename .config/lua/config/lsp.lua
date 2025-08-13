local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()


require('nvim-autopairs').setup{}
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {"go", "gopls", "rust_analyzer", "pyright", "ast-grep", "zls"},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})


local util = require'lspconfig.util'
local lspconfig = require'lspconfig'

local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  -- LSP Keybindings
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

lspconfig.rust_analyzer.setup{
  on_attach=on_attach,
  settings = {
    ["rust-analyzer"] = {
        cargo = {
            allFeatures = true,
            },
        },
  },
}

lspconfig.gopls.setup{
 on_attach=on_attach,
 root_dir = function(fname)
      -- see: https://github.com/neovim/nvim-lspconfig/issues/804
      local mod_cache = vim.trim(vim.fn.system 'go env GOMODCACHE')
      if fname:sub(1, #mod_cache) == mod_cache then
         local clients = vim.lsp.get_active_clients { name = 'gopls' }
         if #clients > 0 then
            return clients[#clients].config.root_dir
         end
      end
      return util.root_pattern 'go.work'(fname) or util.root_pattern('go.mod', '.git')(fname)
   end,
}

lspconfig.zls.setup{}

lspconfig.pyright.setup{
  on_attach=on_attach,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off", -- or "strict" for more detailed checks
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
}

local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['j'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['k'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Up>'] = cmp.config.disable,
        ['<Down>'] = cmp.config.disable,
        ['<Left>'] = cmp.config.disable,
        ['<Right>'] = cmp.config.disable,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    },
    formatting = {
        format = function(entry, vim_item)
            -- Set the details in the completion window
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
            })[entry.source.name]
            return vim_item
        end
    },
})

