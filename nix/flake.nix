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

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
  let
    macUser = "emilalg";
    wslUser = "velho"; # Updated with your actual WSL username
  in
  {
    # --- BLOCK 1: MAC CONFIGURATION ---
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
    }; # <--- Ensure this bracket closes darwinConfigurations

    # --- BLOCK 2: WSL CONFIGURATION ---
    homeConfigurations = {
      "wsl" = home-manager.lib.homeManagerConfiguration {

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          cudaSupport = true;
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
    }; # <--- Ensure this bracket closes homeConfigurations

  }; # <--- Ensure this closes 'outputs'
}