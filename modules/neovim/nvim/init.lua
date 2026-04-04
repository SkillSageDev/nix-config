vim.opt.relativenumber = true

vim.lsp.enable("nixd")

vim.lsp.config("nixd", {
  cmd = { "nixd" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> {}",
        expr = "import (builtins.getFlake (toString ../../../../flake.nix)).nixpkgs {}",
      },
      -- nixpkgs["expr"] = 
    },
    formatting = { 
      command = { "nixfmt" },
    },

    options = { 
      nixos = { 
        expr = "import (builtins.getFlake (toString ../../../../flake.nix)).nixosConfigurations.options {}",
      },
    },
  },

})
