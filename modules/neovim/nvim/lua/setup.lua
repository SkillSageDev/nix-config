vim.opt.relativenumber = true
vim.g.mapleader = " "

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
  capabilities = require("blink.cmp").capabilities,
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
})


vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
  capabilities = require("blink.cmp").capabilities,
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
})

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
