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

  nix.gc = lib.mkIf isLinux {
    automatic = true;
    dates = "weekly"; # <--- RENAMED from 'frequency'
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
  };

  home.packages = with pkgs; [
    # Core
    git
    home-manager # <--- Installs the CLI tool explicitly

    # Dev
    nodejs_24
    pyright
    bun

    # Utils
    btop
    ripgrep
    jq
    fzf # Fuzzy finder (must have)
    wslu

    # gpu
    nvtopPackages.nvidia
  ];

  # --- SHELL CONFIGURATION ---
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true; # <--- Makes commands green/red while typing

    shellAliases = {
      ll = "ls -l";
      # Robust update command
      update = if isDarwin
        then "git -C ${configDir} add . && darwin-rebuild switch --flake ${configDir}"
        else "git -C ${configDir} add . && home-manager switch --flake ${configDir}#wsl";
      upgrade = "nix flake update --flake ${configDir} && update";
    };

    # Fix Path logic on WSL so 'home-manager' command is found
    initContent = ''
      # Source Nix environment
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      ${lib.optionalString isLinux ''
        # 1. The Wiki explicitly says to prefix /usr/lib/wsl/lib
        export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH

        # 2. Also ensure standard binaries (nvidia-smi) are in path
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
      # Customizing the look slightly
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

  home.sessionVariables = {
    EDITOR = "zed";
  };

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
