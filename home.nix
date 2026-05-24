{ config, pkgs, ... }:

{
  imports = [
    ./modules/neovim
    ./modules/direnv
    ./modules/git.nix
    ./modules/bash.nix
    ./modules/noctalia.nix
    ./modules/niri.nix
    ./modules/catppuccin.nix
    ./modules/zoxide.nix
    ./modules/tmux.nix
  ];

  home.username = "skill_sage";
  home.homeDirectory = "/home/skill_sage";

  home.stateVersion = "25.11";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
