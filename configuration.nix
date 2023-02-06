# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";


  # Audio
  #hardware.pulseaudio.enable = false;
  #security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  #};

  #custom
  boot.kernelPackages = pkgs.linuxPackages_latest;  
  boot.kernelParams = [ "i915.force_probe=56a0" ];  
  hardware.opengl.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;


  services.xserver = {
	  enable = true;
	  displayManager.gdm.enable = true;
	  desktopManager.gnome.enable = true;
  };

  #garbage collect 

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  hardware.bluetooth.enable = true;

  #gnome debloat 

  environment.gnome.excludePackages = (with pkgs; [
  gnome-photos
  gnome-tour
  ]) ++ (with pkgs.gnome; [
  cheese # webcam tool
  gnome-music
  gnome-terminal
  gedit # text editor
  epiphany # web browser
  geary # email reader
  evince # document viewer
  gnome-characters
  totem # video player
  tali # poker game
  iagno # go game
  hitori # sudoku game
  atomix # puzzle game
  seahorse
  gnome-contacts
  simple-scan
  gnome-maps
  ]); 

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "fi";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fi";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.velho = {
    isNormalUser = true;
    description = "velho";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
	  gnome-extension-manager
    gnome.gnome-tweaks
    zoom-us
    obsidian
    _1password
    _1password-gui
    discord-canary
    thunderbird
    lutris
    bottles
    spotify
    prismlauncher
    jetbrains.idea-ultimate
    godot_4
    blackbox-terminal
    exa
    gimp
    qbittorrent
    openconnect_unstable
    youtube-music
    lapce
    helix
    ];
  };

  
  programs.dconf.enable = true;

  services.ratbagd.enable = true;
  services.flatpak.enable = true;
  programs.steam.enable = true;
  programs.noisetorch.enable = true;
  security.sudo.wheelNeedsPassword = false;

  #zsh as default
  users.defaultUserShell = pkgs.zsh;
  #zsh
  environment.pathsToLink = [ "/share/zsh" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    virt-manager
    spice-gtk
    jdk
  ];

  #virt
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;

  #security.wrappers.spice-client-glib-usb-acl-helper.owner = "velho";
  #ecurity.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

  #fonts

  fonts.fonts = with pkgs; [
  fira-code
  fira-code-symbols
  roboto
  (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  nixpkgs.overlays = [
     (self: super: {
       discord-canary = super.discord-canary.overrideAttrs (
         _: { src = builtins.fetchTarball {
          url = https://discord.com/api/canary/download?platform=linux&format=tar.gz;
          sha256 = "0cp7n4h1v59kwihg54px47p5n7hhcjjjwbvrh6pbg2333rhgjff4";
         }; }
       );
     })
  ];

  
  

}
