{ config, pkgs, ... }:

{
  # Import the Python data science environment
  imports = [ ./python.nix ];
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "emilalg";
  home.homeDirectory = "/Users/emilalg";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11"; # Please check the latest version

  # Packages to install
  home.packages = with pkgs; [
    # Development tools
    git
    nodejs_24
    pyright
    ngrok
  ];

  # Program-specific configurations
  programs = {
    # NOTE: Removed home-manager.enable = true; since nix-darwin handles this

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      shellAliases = {
        # Updated alias to use the new unified config location
        update = "sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix";
      };

      initContent = ''
        # Add vscode to path
        export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

        # Note: nix-darwin will handle the Nix daemon sourcing automatically
      '';
    };

    # Direnv for automatic environment loading
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;  # Better nix-shell/flake integration
    };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "code";  # or your preferred editor
  };
}
