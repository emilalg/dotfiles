{ config, pkgs, lib, user, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # Import your Python Module
  imports = [ ./python-env.nix ];

  # Basic Info
  home.username = lib.mkDefault user;
  home.homeDirectory = lib.mkDefault (if isDarwin then "/Users/${user}" else "/home/${user}");
  home.stateVersion = "24.05"; 

  # Packages installed on BOTH Mac and WSL
  home.packages = with pkgs; [
    git
    nodejs_22 # Latest stable
    pyright
    ngrok
    # Add system monitors, etc.
    btop
    ripgrep
    jq
  ];

  # Program Configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    
    shellAliases = {
      ll = "ls -l";
      # Update command adapts to OS
      update = if isDarwin 
        then "darwin-rebuild switch --flake ~/.config/nix"
        else "home-manager switch --flake ~/.config/nix#wsl";
    };

    initExtra = ''
      # Add VS Code to path (Mac specific)
      ${lib.optionalString isDarwin ''export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"''}
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "code";
  };
}