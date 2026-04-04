vim.opt.relativenumber = true

vim.lsp.enable("nixd")

vim.lsp.config("nixd", {
  cmd = { "nixd" },
  capabilities = require("blink.cmp").get_lsp_capabilites,
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> {}",
        expr = "import (builtins.getFlake (toString ../../../../flake.nix)).nixpkgs {}",
      },
    },
    formatting = { 
      command = { "nixfmt" },
    },

    options = { 
      nixos = { 
        expr = "(builtins.getFlake (toString ../../../../flake.nix)).nixosConfigurations.nixos.options",
      },
      home_manager = { 
        expr = '(builtins.getFlake (toString ../../../../flake.nix)).homeConfigurations.skill_sage.options',
      },
    },
  },

})

vim.lsp.enable("dartls")

vim.lsp.config("dartls", {
  capabilities = require("blink.cmp").get_lsp_capabilites,
})

require("blink.cmp").setup({})
require("flutter-tools").setup({})
