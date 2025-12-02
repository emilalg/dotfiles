{ config, pkgs, lib, user, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  configDir = "~/.config/nix";

  # Define the libraries UV/Python binaries usually need
  nixLdLibraries = with pkgs; [
    stdenv.cc.cc.lib  # libstdc++
    zlib
    glib
    libGL
    libxml2
    openssl

    # Misc
    libffi
    readline
    sqlite
    ncurses
    expat
    tbb
    numactl

    # Common X11/GUI libs
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libICE
    xorg.libSM

    libjpeg
    libpng
    libtiff
    libwebp

    # --- Audio (Required for torchaudio) ---
    libsndfile
    sox
    alsa-lib    # <--- CRITICAL for torchaudio
    libpulseaudio

    # Audio/Video
    ffmpeg
    libsndfile
    sox
  ];
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
    # Core Tools
    nix-ld        # <--- REQUIRED for the shim to exist
    uv            # <--- Your tool of choice

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

  # --- ENVIRONMENT VARIABLES (Merged) ---
  home.sessionVariables = {
    EDITOR = "zed";
    # Set UV to use only managed Python environments
    UV_PYTHON_PREFERENCE = "only-managed";
  } // lib.optionalAttrs isLinux {
    # 1. Point NIX_LD to the dynamic linker path
    NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";

    # 2. Set the library path for nix-ld to find dependencies
    #    We also append the WSL lib path here so Python can find CUDA/DirectML
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath nixLdLibraries + ":/usr/lib/wsl/lib";
  };

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

      # WSL Path Fixes (Only modify PATH, not LD_LIBRARY_PATH)
      ${lib.optionalString isLinux ''
        export PATH=$PATH:/usr/lib/wsl/lib
      ''}

      ${lib.optionalString isDarwin ''export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"''}
    '';
  };

  programs.starship = { enable = true; enableZshIntegration = true; };
  programs.direnv = { enable = true; enableZshIntegration = true; nix-direnv.enable = true; };
  # REMOVED: home.sessionVariables = { EDITOR = "zed"; }; (Merged above)

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
