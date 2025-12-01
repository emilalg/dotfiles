{
  description = "My unified nix-darwin + home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager }:
  {
    darwinConfigurations."Emils-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [
        # Main system configuration
        ({ pkgs, ... }: {
          # List packages installed in system profile
          environment.systemPackages = with pkgs; [
            vim
          ];

          # NOTE: Removed services.nix-daemon.enable = true; as it's deprecated
          # nix-darwin now manages nix-daemon automatically when nix.enable is on
          
	  nixpkgs.config.allowUnfree = true;

          # Necessary for using flakes on this system
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment
          programs.zsh.enable = true;

          security.pam.services.sudo_local.touchIdAuth = true;

          # Set Git commit hash for darwin-version
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing
          system.stateVersion = 4;

          # The platform the configuration will be used on
          nixpkgs.hostPlatform = "aarch64-darwin";

          # Define your user
          users.users.emilalg = {
            name = "emilalg";
            home = "/Users/emilalg";
          };

          # Fix GID mismatch for build users
          ids.gids.nixbld = 350;
        })

        # Home Manager configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emilalg = import ./home.nix;
        }
      ];
    };
    
    darwinPackages = self.darwinConfigurations."Emils-MacBook-Air".pkgs;
  };
}
