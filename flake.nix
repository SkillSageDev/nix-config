{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in {
    
    nixosConfigurations = {
      nixos = lib.nixosSystem {
	inherit system;
	modules = [ ./configuration.nix ];
      };
    };

  };
}
