{ pkgs, user, ... }:
{
  # System Packages (Available to all users)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Nix Settings
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User Configuration
  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  # System Defaults
  security.pam.services.sudo_local.touchIdAuth = true;
  system.stateVersion = 4;
  
  # ZSH (Managed by Home Manager, but enabled here for system paths)
  programs.zsh.enable = true;

  # Build User IDs
  ids.gids.nixbld = 350;
}
