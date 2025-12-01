{
  description = "Unified Emil's Nix Config (Darwin + WSL)";
  # https://docs.determinate.systems/


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # --- UPDATED CACHE CONFIG (CRITICAL) ---
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org" # <--- NEW URL
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" # <--- NEW KEY
    ];
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
  let
    macUser = "emilalg";
    wslUser = "velho";
  in
  {
    darwinConfigurations = {
      "Emils-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; user = macUser; };
        modules = [ 
          ./hosts/macbook/default.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; user = macUser; };
            home-manager.users.${macUser} = import ./home/default.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      "wsl" = home-manager.lib.homeManagerConfiguration {
        # Keep cudaSupport = true, now that we have the right cache
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        extraSpecialArgs = { inherit inputs; user = wslUser; };
        modules = [ 
          ./home/default.nix 
          {
            home.username = wslUser;
            home.homeDirectory = "/home/${wslUser}";
            targets.genericLinux.enable = true;
          }
        ];
      };
    };
  };
}