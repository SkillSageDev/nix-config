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

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, home-manager, sops-nix, xremap-flake, sysc-greet, noctalia, niri, ... }: 
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsUnfree = import nixpkgs {
        inherit system;
	config.allowUnfree = true;
      };
    in {
    
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        specialArgs = { inherit xremap-flake; inherit sops-nix; inherit sysc-greet; };
	inherit system;
	modules = [ 
	  ./configuration.nix 
	  ./modules/xremap.nix
	  ./modules/sops.nix 
	  ./modules/sysc-greet.nix

          home-manager.nixosModules.home-manager {
	    home-manager = {
	      extraSpecialArgs = { inherit noctalia; inherit niri; };
              useUserPackages = true;
              useGlobalPkgs = true;
              backupFileExtension = "backup";
	      users.skill_sage = import ./home.nix;
	    };
	  }

	];
      };
    };

    devShells.${system} = {
      flutter = import ./shells/flutter.nix { pkgs = pkgsUnfree; };
    };
  };
}
