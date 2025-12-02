{ config, pkgs, lib, user, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  configDir = "~/.config/nix";
in
{
  imports = [ ./python-env.nix ];

  home.username = lib.mkDefault user;
  home.homeDirectory = lib.mkDefault (if isDarwin then "/Users/${user}" else "/home/${user}");
  home.stateVersion = "24.05";

  nix.package = pkgs.nix;

  # --- GARBAGE COLLECTION ---
  nix.gc = lib.mkIf isLinux {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- NIX SETTINGS ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
    auto-optimise-store = true;
  };

  home.packages = with pkgs; [
    # Core
    git
    home-manager

    # Dev
    nodejs_24 # LTS (Recommended over 24 for stability)
    pyright
    bun

    # Utils
    btop
    ripgrep
    jq
    fzf
    wslu

    # GPU
    nvtopPackages.nvidia
  ];

  # --- SHELL CONFIGURATION ---
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      # Robust update command
      update = if isDarwin
        then "git -C ${configDir} add . && darwin-rebuild switch --flake ${configDir}"
        else "git -C ${configDir} add . && home-manager switch --flake ${configDir}#wsl";
      upgrade = "nix flake update --flake ${configDir} && update";
    };

    # Fix Path logic so commands are found
    initContent = ''
      # Source Nix environment
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      ${lib.optionalString isLinux ''
        # Ensure standard binaries (nvidia-smi, wslpath) are in path
        export PATH=/usr/lib/wsl/lib:$PATH
      ''}

      # Add VS Code (Mac only)
      ${lib.optionalString isDarwin ''export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"''}
    '';
  };

  # --- PRETTY PROMPT (STARSHIP) ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # --- GLOBAL ENVIRONMENT VARIABLES ---
  home.sessionVariables = {
    EDITOR = "zed";

    # CRITICAL FIX: Make C++ libs available globally for 'uv', 'pip', and generic wheels
    LD_LIBRARY_PATH = lib.mkIf isLinux (lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib # libstdc++.so.6
      pkgs.zlib
      pkgs.glib
      pkgs.libGL
      pkgs.libxml2
    ] + ":/usr/lib/wsl/lib"); # Append WSL GPU drivers
  };

  # --- AUTOMATION SCRIPT ---
  home.activation = lib.mkIf isLinux {
      linkWindowsHome = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # 1. Vital: Add /usr/bin to PATH so 'wslvar' can find the system 'wslpath'
        export PATH=$PATH:/usr/bin

        # 2. Get the Windows Home Directory
        # We use the absolute path for wslpath just to be safe
        WIN_HOME=$(/usr/bin/wslpath "$(${pkgs.wslu}/bin/wslvar USERPROFILE)")

        # 3. Create the symlink
        # $HOME/emilalg -> /mnt/c/Users/emilalg
        WIN_USER=$(basename "$WIN_HOME")

        if [ -d "$WIN_HOME" ]; then
          $DRY_RUN_CMD ln -sfn "$WIN_HOME" "$HOME/$WIN_USER"
        else
          echo "Warning: Could not find Windows home at $WIN_HOME"
        fi
      '';
    };
}
