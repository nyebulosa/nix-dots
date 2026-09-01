{
  description = "Nebulosa yahooo hi";

  inputs = {
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

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-mineral = {
      url = "github:cynicsketch/nix-mineral/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Shared modules used across all configurations
      sharedModules = [
        ./modules/default.nix
        ./configuration.nix
        inputs.disko.nixosModules.disko
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.chaotic.nixosModules.default

        { home-manager.extraSpecialArgs = { inherit inputs; }; }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.leonillo = {
              imports = [
                ./home.nix
                ./modules/home
                inputs.catppuccin.homeModules.catppuccin
              ];
            };
          };
        }
      ];

      # hostName has to match the directory and the `networking.hostName` set
      # inside it, so `nixos-rebuild --flake .` auto-selects the right one
      mkHost =
        hostName: extraModules:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [ ./hosts/${hostName}/${hostName}.nix ] ++ extraModules;
        };
    in
    {
      # NixOS System Configurations
      nixosConfigurations = {
        thousandsunny = mkHost "thousandsunny" [ ];

        goingmerry = mkHost "goingmerry" [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };

      # `nix fmt` formats every .nix file in the repo
      formatter.${system} = pkgs.nixfmt-tree;

      # `nix develop` for working on this repo itself
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nixfmt
          statix
          deadnix
          nix-tree
          sbctl
        ];
      };
    };
}
