vim.opt.relativenumber = true
vim.g.mapleader = " "

vim.lsp.enable("nixd")
vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git", },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import (builtins.getFlake (builtins.toString ./.)).nixpkgs {}",
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
	home_manager = {
	  expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []",
	},
      },
    },
  },
})

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

vim.cmd.colorscheme "catppuccin"
