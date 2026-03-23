{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs = { nixpkgs, home-manager, sops-nix, xremap-flake, ... }: 
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
	  sops-nix.nixosModules.default
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
