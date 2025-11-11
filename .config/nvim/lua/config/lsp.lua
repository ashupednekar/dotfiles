-- nvim-autopairs is a quality-of-life plugin that automatically closes pairs of
-- characters like (), [], {}, "", and ''. It is highly recommended to keep it.
require('nvim-autopairs').setup{}

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false, silent = true }

  -- See :help lsp-zero-keybindings
  -- To see all the keybindings that are created, uncomment the line below.
  -- print(vim.inspect(lsp.get_keymaps()))
  lsp.default_keymaps({ buffer = bufnr })
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Format on save
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { "gopls", "rust_analyzer", "zls", "pyright", "html", "cssls", "emmet_ls", "tailwindcss" },
  handlers = {
    lsp.default_setup,
    gopls = function()
      require('lspconfig').gopls.setup({
        on_attach = lsp.on_attach,
        settings = {
          gopls = {
            root_dir = function(fname)
              -- see: https://github.com/neovim/nvim-lspconfig/issues/804
              local mod_cache = vim.trim(vim.fn.system 'go env GOMODCACHE')
              if fname:sub(1, #mod_cache) == mod_cache then
                local clients = vim.lsp.get_active_clients { name = 'gopls' }
                if #clients > 0 then
                  return clients[#clients].config.root_dir
                end
              end
              return require('lspconfig.util').root_pattern 'go.work'(fname) or require('lspconfig.util').root_pattern('go.mod', '.git')(fname)
            end,
          }
        }
      })
    end,
    rust_analyzer = function()
      require('lspconfig').rust_analyzer.setup({
        on_attach = lsp.on_attach,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = "clippy",
            },
            build = {
              allFeatures = true,
            },
            -- Add this to use leptosfmt
            ["rustfmt"] = {
              extraArgs = {"+nightly", "leptosfmt"},
            }
          },
        },
      })
    end,
    pyright = function()
        require('lspconfig').pyright.setup{
            on_attach=lsp.on_attach,
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
    end,
    tailwindcss = function()
        require('lspconfig').tailwindcss.setup({
            on_attach = lsp.on_attach,
        })
    end,
  }
})

lsp.setup()

local cmp = require('cmp')
cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'emmet_ls' },
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
        emmet_ls = "[Emmet]",
      })[entry.source.name]
      return vim_item
    end
  },
})
