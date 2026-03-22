{ xremap-flake, ... }:

{

  imports = [ xremap-flake.nixosModules.default ]; 

  services.xremap = {
    enable = true;
    config = {
      modmap = [{
        name = "Global";
        remap = { "CapsLock" = "Esc"; };
      }];
    };
  };

}
