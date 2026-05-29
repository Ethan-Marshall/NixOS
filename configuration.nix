# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  # creates symlinks to Dotfile @ /etc/nixos/dotfiles
  system.activationScripts.dotfileSymlinks = {
    text = ''
      rm -rf /home/ethan/.config/niri
      rm -rf /home/ethan/.config/noctalia
      rm -rf /home/ethan/.config/ghostty
      rm -rf /home/ethan/.config/fastfetch
      rm -rf /home/ethan/.config/btop
      rm -rf /home/ethan/.config/fish
      rm -rf /home/ethan/.config/starship.toml
      rm -rf /home/ethan/.local/share/nemo/actions
      rm -rf /home/ethan/.local/share/nemo/scripts
      rm -rf /home/ethan/.config/yazi
      rm -rf /home/ethan/.config/gtk-3.0
      rm -rf /home/ethan/.config/gtk-4.0
      rm -rf /home/ethan/.config/xsettingsd
      rm -rf /home/ethan/.gtkrc-2.0


      ln -sfn /etc/nixos/dotfiles/niri /home/ethan/.config/niri
      ln -sfn /etc/nixos/dotfiles/noctaliaV5 /home/ethan/.config/noctalia
      ln -sfn /etc/nixos/dotfiles/ghostty /home/ethan/.config/ghostty
      ln -sfn /etc/nixos/dotfiles/fastfetch /home/ethan/.config/fastfetch
      ln -sfn /etc/nixos/dotfiles/btop /home/ethan/.config/btop
      ln -sfn /etc/nixos/dotfiles/fish /home/ethan/.config/fish
      ln -sfn /etc/nixos/dotfiles/starship/starship.toml /home/ethan/.config/starship.toml
      ln -sfn /etc/nixos/dotfiles/nemo/actions /home/ethan/.local/share/nemo/actions
      ln -sfn /etc/nixos/dotfiles/nemo/scripts /home/ethan/.local/share/nemo/scripts
      ln -sfn /etc/nixos/dotfiles/yazi /home/ethan/.config/yazi
      ln -sfn /etc/nixos/dotfiles/GTK/gtk-3.0 /home/ethan/.config/gtk-3.0
      ln -sfn /etc/nixos/dotfiles/GTK/gtk-4.0 /home/ethan/.config/gtk-4.0
      ln -sfn /etc/nixos/dotfiles/GTK/xsettingsd /home/ethan/.config/xsettingsd
      ln -sfn /etc/nixos/dotfiles/GTK/.gtkrc-2.0 /home/ethan/.gtkrc-2.0
    '';
  };  

  # Run Garbage Collection Weekly to Cleanup Generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Only Show The 10 Most Recent Generations at Boot Menu
  boot.loader.systemd-boot.configurationLimit = 10;
  # Reduce Boot Messages
  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" "nowatchdog" "nmi_watchdog=0" "udev.log_level=0" "acpi=force" ];
  
  powerManagement.enable = true;
  services.acpid.enable = true;

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
    RuntimeWatchdogSec = "0";
    RebootWatchdogSec = "0";
  };

  # Init
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.initrd.systemd.tpm2.enable = true;
  # Need to run in terminal:
     # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p2
     # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p3

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Swap LUKS
  boot.initrd.luks.devices."luks-7e1e369d-50ef-44e9-9902-a690579591d3".device = "/dev/disk/by-uuid/7e1e369d-50ef-44e9-9902-a690579591d3";

  # Clean /tmp on Boot, Used for fish_greeting
  boot.tmp.cleanOnBoot = true;
  
  # Define your hostname.  
  networking.hostName = "FracturedStack";

  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = "America/Phoenix";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ethan = {
    isNormalUser = true;
    description = "Ethan Marshall";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  # Set Git User
  programs.git = {
      enable = true;
      config = [
        {
          user = {
            name = "Ethan Marshall";
            email = "113003659+Ethan-Marshall@users.noreply.github.com";
          };
          init = {
            defaultBranch = "main";
          };
        }
      ];
  };
  
  # Enable Fingerprint Authentication and Add to PAM
  services.fprintd.enable = true;
  security.pam.services.system-login.fprintAuth = true;
  # Polkit required for printd authentication
  security.polkit.enable = true;
  # ! Have to run sudo fprintd-enroll ethan to enroll fingerprint
  
  # Home-Manager Managed Settings
  home-manager.users.ethan = { pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [

    # Home-Manager User Packages

    ];
    
    # The state version is required and should stay at the version you originally installed
    home.stateVersion = "25.11";
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed at system level.
  environment.systemPackages = with pkgs; [
  # Leave alacritty for sake of if I break Niri, Niri default config points to alacritty for keybind
    alacritty
    qt6Packages.qt6ct
    gtk3
    dracula-theme
    papirus-icon-theme
    bibata-cursors
    nwg-look
    tpm2-tss
    wget
    gh
    github-desktop
    vscodium
    neovim
    ghostty
    nemo
    nemo-fileroller # right click archive creation/extraction
    ffmpegthumbnailer # video thumbnails
    evince # pdf previews
    yazi
    fastfetch
    btop
    starship
    efibootmgr
    ffmpeg
    mpvpaper
    libreoffice
    vlc
    gimp
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # fonts defined at the system level are not always applied to users
  fonts = {
    packages = with pkgs; [
      nerd-fonts.monaspace
      geist-font
      twemoji-color-font
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      adwaita-fonts
    ];

    fontDir.enable = true;

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "MonaspiceNe Nerd Font Mono" ];
        sansSerif = [ "Geist" ];
        emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
      };
    };
  };


  # Adds thumbnail generation for Nemo file manager
  services.tumbler.enable = true;    

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  
  programs.xwayland.enable = true;  
  services.xserver.enable = true;
 
  # Enable Niri
  programs.niri.enable = true;
  
  # Enable SDDM Display Manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "niri";

  # Configure automatic login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ethan";

  # List services that you want to enable:
  
  # Required for Noctalia
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # GVFS provides backend for trash, network, and other locations for Nautilus
  services.gvfs.enable = true;

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
  system.stateVersion = "25.11"; # Did you read the comment?

}
