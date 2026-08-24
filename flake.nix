{
  description = "NixOS & Home Manager Configuration (Architecture 2026)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags/v1";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    airi = {
      url = "github:09641061/airi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, spicetify-nix, stylix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            nodePackages = {
              typescript = final.typescript;
            };
          })
        ];
      };
      specialArgs = { inherit inputs; };
    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/desktop
            sops-nix.nixosModules.sops
            spicetify-nix.nixosModules.default
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.pkgs = pkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.rylai = import ./home/rylai;
            }
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/laptop
            sops-nix.nixosModules.sops
            spicetify-nix.nixosModules.default
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.pkgs = pkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.rylai = import ./home/rylai;
            }
          ];
        };
      };
    };
}
