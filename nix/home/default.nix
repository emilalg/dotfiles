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
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
  };

  home.packages = with pkgs; [
    git
    home-manager
    nodejs_24
    pyright
    bun
    btop
    ripgrep
    jq
    fzf
    wslu
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
      update = if isDarwin
        then "git -C ${configDir} add . && darwin-rebuild switch --flake ${configDir}"
        else "git -C ${configDir} add . && home-manager switch --flake ${configDir}#wsl";
      upgrade = "nix flake update --flake ${configDir} && update";
    };

    initContent = ''
      # Source Nix environment
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      ${lib.optionalString isLinux ''
        # --- THE FIX FOR UV / PYTHON WHEELS ---
        # As per the Nix-LD FAQ: Python venvs need LD_LIBRARY_PATH set directly.
        # We build a path containing the standard C++ libraries that wheels expect.

        NIX_LIBS="${lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib # C++ Standard Library
          pkgs.zlib
          pkgs.glib
          pkgs.libGL            # OpenGL/CV2
          pkgs.libxml2
          pkgs.openssl

          # --- FIXED X11 LIBRARIES (Prefix with xorg.) ---
          pkgs.xorg.libX11
          pkgs.xorg.libXext
          pkgs.xorg.libXrender
          pkgs.xorg.libICE
          pkgs.xorg.libSM

          # Audio/Video
          pkgs.ffmpeg
          pkgs.libsndfile
          pkgs.sox
        ]}"

        # We Prepend Nix Libs + Append WSL GPU drivers
        export LD_LIBRARY_PATH="$NIX_LIBS:/usr/lib/wsl/lib:$LD_LIBRARY_PATH"

        # Ensure standard binaries (wslpath, nvidia-smi) are in path
        export PATH=$PATH:/usr/lib/wsl/lib
      ''}

      ${lib.optionalString isDarwin ''export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"''}
    '';
  };

  programs.starship = { enable = true; enableZshIntegration = true; };
  programs.direnv = { enable = true; enableZshIntegration = true; nix-direnv.enable = true; };
  home.sessionVariables = { EDITOR = "zed"; };

  home.activation = lib.mkIf isLinux {
      linkWindowsHome = lib.hm.dag.entryAfter ["writeBoundary"] ''
        export PATH=$PATH:/usr/bin
        WIN_HOME=$(/usr/bin/wslpath "$(${pkgs.wslu}/bin/wslvar USERPROFILE)")
        WIN_USER=$(basename "$WIN_HOME")
        if [ -d "$WIN_HOME" ]; then
          $DRY_RUN_CMD ln -sfn "$WIN_HOME" "$HOME/$WIN_USER"
        else
          echo "Warning: Could not find Windows home at $WIN_HOME"
        fi
      '';
    };
}
