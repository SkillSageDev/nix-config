{ sysc-greet, ... }:

{
  imports = [ sysc-greet.nixosModules.default ];

  services.greetd.enable = true;

  services.sysc-greet = {
    enable = true;
    compositor = "niri";
  };
}
