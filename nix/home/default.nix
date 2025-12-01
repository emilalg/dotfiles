{ config, pkgs, lib, user, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # The path to your config
  configDir = "~/.config/nix";
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
    nodejs_22
    pyright
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
      
      # --- ROBUST UPDATE COMMAND ---
      # 1. Navigates to config dir via 'git -C'
      # 2. Stages all new files (fixes the "missing attribute" error)
      # 3. Rebuilds the system based on OS
      update = if isDarwin 
        then "git -C ${configDir} add . && darwin-rebuild switch --flake ${configDir}"
        else "git -C ${configDir} add . && home-manager switch --flake ${configDir}#wsl";
        
      # Optional: Command to strictly update versions (flake.lock)
      upgrade = "nix flake update --flake ${configDir} && update";
    };

    initContent = ''
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