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
        specialArgs = { inherit xremap-flake; inherit sops-nix; };
	inherit system;
	modules = [ 
	  ./configuration.nix 
	  ./modules/xremap.nix
	  ./modules/sops.nix 

          # FIXME: something broke "programs.neovim.defaultEditor = true;" after I added sops.nix for git
          home-manager.nixosModules.home-manager {
	    home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              backupFileExtension = "backup";
	      users.skill_sage = import ./home.nix;
	    };
	  }

	];
      };
    };

  };
}
