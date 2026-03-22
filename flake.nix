{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs = { nixpkgs, home-manager, agenix, xremap-flake, ... }: 
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        specialArgs = { inherit xremap-flake; };
	inherit system;
	modules = [ 
	  ./configuration.nix 
	  agenix.nixosModules.default
	  ./modules/xremap.nix
	];
      };
    };

    homeConfigurations =  {
      skill_sage = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
	  ./home.nix
	];
      };
    };

  };
}
