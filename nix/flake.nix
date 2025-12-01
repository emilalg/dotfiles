{
  description = "Unified Emil's Nix Config (Darwin + WSL)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
  let
    # --- CONFIGURATION VARIABLES ---
    macUser = "emilalg";
    wslUser = "velho"; # Your specific WSL username here
    # -------------------------------
  in
  {
    # 1. MacOS Configuration
    darwinConfigurations = {
      "Emils-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        
        # Pass the MAC user to the modules
        specialArgs = { inherit inputs; user = macUser; };
        
        modules = [ 
          ./hosts/macbook/default.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            # Pass the MAC user to Home Manager module
            home-manager.extraSpecialArgs = { inherit inputs; user = macUser; };
            
            # Key must match the actual username
            home-manager.users.${macUser} = import ./home/default.nix;
          }
        ];
      };
    };

    # 2. WSL Configuration
    homeConfigurations = {
      "wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        
        # Pass the WSL user to the modules
        extraSpecialArgs = { inherit inputs; user = wslUser; };
        
        modules = [ 
          ./home/default.nix 
          {
            # Explicitly force the WSL identity
            home.username = wslUser;
            home.homeDirectory = "/home/${wslUser}";
            targets.genericLinux.enable = true;
          }
        ];
      };
    };
  };
}