{ config, pkgs, ... }:

{
  imports  = [ 
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/bash.nix
  ];

  home.username = "skill_sage";
  home.homeDirectory = "/home/skill_sage";

  home.stateVersion = "25.11"; 

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
