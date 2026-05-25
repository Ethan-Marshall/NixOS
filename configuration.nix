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
      rm -rf /home/ethan/.config/fish

      ln -sfn /etc/nixos/dotfiles/niri /home/ethan/.config/niri
      ln -sfn /etc/nixos/dotfiles/noctalia /home/ethan/.config/noctalia
      ln -sfn /etc/nixos/dotfiles/ghostty /home/ethan/.config/ghostty
      ln -sfn /etc/nixos/dotfiles/fish /home/ethan/.config/fish
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

  # Init
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  # Need to run in terminal:
     # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p2
     # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p3

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Swap LUKS
  boot.initrd.luks.devices."luks-7e1e369d-50ef-44e9-9902-a690579591d3".device = "/dev/disk/by-uuid/7e1e369d-50ef-44e9-9902-a690579591d3";

  # Clean /tmp on boot
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
  papirus-icon-theme
  tpm2-tss
  wget
  gh
  rofi
  ghostty
  yazi
  fastfetch
  nautilus
  btop
  inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];


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
  
  # Enable SDDM Display Manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "niri";

  # Configure automatic login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ethan";

  # List services that you want to enable:
  
  # required for Noctalia
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

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
