{
  description = "leoNillo's flake";

  inputs = {
    # Official NixOS packages (nixpkgs)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-mineral = {
      url = "github:cynicsketch/nix-mineral/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      # Shared modules used across all configurations
      sharedModules = [
        ./modules/default.nix
        ./configuration.nix
        inputs.disko.nixosModules.disko
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default
        inputs.impermanence.nixosModules.impermanence

        { home-manager.extraSpecialArgs = { inherit inputs; }; }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.leonillo = {
              imports = [
                ./home.nix
                inputs.catppuccin.homeModules.catppuccin
              ];
            };
          };
        }
      ];
    in
    {
      # NixOS System Configurations
      nixosConfigurations = {
        "thousandsunny" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [ ./hosts/thousandsunny/thousandsunny.nix ];
        };

        "goingmerry" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/goingmerry/goingmerry.nix
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            # inputs.lanzaboote.nixosModules.lanzaboote
          ];
        };
      };
    };
}
