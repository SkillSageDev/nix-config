{ config, pkgs, ... }:

{
  imports = [
    ./modules/neovim
    ./modules/git.nix
    ./modules/bash.nix
    ./modules/noctalia.nix
    ./modules/niri.nix
  ];

  home.username = "skill_sage";
  home.homeDirectory = "/home/skill_sage";

  home.stateVersion = "25.11";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
