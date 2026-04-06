vim.opt.relativenumber = true
vim.g.mapleader = " "

vim.lsp.enable("nixd")
vim.lsp.config("nixd", {
  cmd = { "nixd" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  settings = {
    nixd = { -- Everything must be inside this block
      nixpkgs = {
        expr = 'import (builtins.getFlake (toString ../../../../flake.nix)).inputs.nixpkgs { }',
      },
      formatting = { 
        command = { "nixfmt" },
      },
      options = { 
        nixos = {
          expr = '(builtins.getFlake (toString ../../../../flake.nix)).nixosConfigurations.nixos.options',
        },

        -- home_manager = { 
        --   expr = '(builtins.getFlake /home/skill_sage/nix-config/flake.nix).nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []',
        -- },
      },
    },
  },
})

-- vim.lsp.config("nixd", {
--   cmd = { "nixd" },
--   capabilities = require("blink.cmp").get_lsp_capabilities(),
--   settings = {
--     nixd = {
--       nixpkgs = {
--         expr = "import (builtins.getFlake (toString ../../../../flake.nix)).nixpkgs {}",
--       },
--     },
--
--     formatting = { 
--       command = { "nixfmt" },
--     },
--
--     options = { 
--       nixos = {
--         expr = "(builtins.getFlake (toString ../../../../flake.nix)).nixosConfigurations.nixos.options",
--       },
--
--       home_manager = { 
--         expr = "(builtins.getFlake (toString ../../../../flake.nix)).nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []",
--       },
--
--     },
--   },
--
-- })

require("snacks").setup({
  notifier = { enabled = true, },
  picker = { enabled = true, },
  bigfile = { enabled = true, },
  dashboard = { enabled = true, },
  explorer = { enabled = true, },
  indent = { enabled = true, },
  input = { enabled = true, },
  quickfile = { enabled = true, },
  scope = { enabled = true, },
  scroll = { enabled = true, },
  statuscolumn = { enabled = true, },
  words = { enabled = true, },
  image = { enabled = true, },
})

require("blink.cmp").setup({})

require("flutter-tools").setup({
  lsp = {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})

vim.opt.termguicolors = true
