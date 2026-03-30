{ noctalia, pkgs, ... }:

{
  imports = [ noctalia.homeModules.default ];

  home.packages = with pkgs; [
    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
  };
}
