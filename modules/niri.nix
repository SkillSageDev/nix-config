{ niri, osConfig, ... }:

{
  imports = [ niri.homeModules.niri ];

  programs.niri = {
    enable = true;
    settings = import ./niri-settings.nix;
  };
}
