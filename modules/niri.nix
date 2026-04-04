{ niri, ... }:

{
  imports = [
    niri.homeModules.niri
    ./niri-settings.nix
  ];

  programs.niri = {
    enable = true;
  };
}
