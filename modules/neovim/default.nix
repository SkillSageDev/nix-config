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
    ];

    # initLua = builtins.readFile ./nvim/init.lua;
  };

  home.packages = with pkgs; [
    # snacks required packages
    ripgrep
    ghostscript
    tectonic
    mermaid-cli
    imagemagick
    sqlite
  ];

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/skill_sage/nix-config/modules/neovim/nvim";

  xdg.configFile."nvim/init.lua".enable = false;

  # xdg.configFile."nvim".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/neovim/nvim/lua";

  # xdg.configFile."nvim".source = ./nvim;
}
