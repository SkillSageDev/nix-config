{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      blink-cmp
      flutter-tools-nvim
      plenary-nvim
      snacks-nvim
      nvim-treesitter.withAllGrammars
    ];
  };

  home.packages = with pkgs; [
    # snacks required packages
    ripgrep
    ghostscript
    tectonic
    mermaid-cli
    imagemagick
    sqlite
    gcc
    tree-sitter

    lua-language-server
  ];

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/skill_sage/nix-config/modules/neovim/nvim";

  xdg.configFile."nvim/init.lua".enable = false;
}
