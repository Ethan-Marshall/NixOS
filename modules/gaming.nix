# modules/gaming.nix — Steam, Proton, and gaming utilities
#
# Steam on NixOS requires the programs.steam module rather than just adding
# steam to environment.systemPackages. The module handles 32-bit multilib
# library setup that Steam and Proton need to run Windows games. Without it
# you will get missing library errors when launching games.
#
# PROTON:
# Proton is Steam's built-in Windows compatibility layer (based on Wine + DXVK).
# It is bundled with Steam and requires no separate installation. You can also
# install Proton-GE (a community build with extra patches) via ProtonUp-Qt.
#
# GAMEMODE:
# GameMode is a daemon by Feral Interactive that temporarily applies performance
# optimizations when a game launches (CPU governor, scheduler tweaks, etc).
# programs.gamemode.enable installs it and sets up the required setuid wrapper.
# Games need to be launched with `gamemoderun %command%` in Steam launch options,
# or you can enable it globally via programs.gamemode.enableRenice.
#
# MANGOHUD:
# MangoHud is an overlay that displays real-time GPU/CPU usage, temps, FPS,
# and frame times on top of running games. Add MANGOHUD=1 to a game's Steam
# launch options to enable it per-game, or set it globally in the environment.
#
# CONTROLLER SUPPORT:
# Steam handles most controllers natively via udev rules it ships with.
# For controllers that need extra udev rules (e.g. DualSense, Switch Pro),
# hardware.steam-hardware.enable covers the most common cases.

{ pkgs, ... }:
{
  # ── Steam ────────────────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;

    # Opens firewall ports for Steam Remote Play (streaming games to other
    # devices on your local network). Safe to leave enabled, remove if unused.
    remotePlay.openFirewall = true;

    # Opens firewall ports for Steam's local network game transfers (downloading
    # games from another PC on the same LAN instead of from Steam servers).
    localNetworkGameTransfers.openFirewall = true;

    # Extra packages made available inside Steam's pressure-vessel container.
    # Useful for tools that games call at runtime (e.g. mangohud inside Proton).
    extraPackages = with pkgs; [
      # mangohud  # uncomment if you want MangoHud available inside Steam games
    ];
  };

  # ── GameMode ─────────────────────────────────────────────────────────────────
  # Feral Interactive's performance optimization daemon. Applies CPU governor
  # changes and scheduler hints when a game is running.
  # To use per-game in Steam: add `gamemoderun %command%` to launch options.
   programs.gamemode.enable = true;

  # ── MangoHud ─────────────────────────────────────────────────────────────────
  # In-game performance overlay (FPS, frametimes, GPU/CPU usage, temps).
  # To enable per-game in Steam: add `MANGOHUD=1 %command%` to launch options.
  # programs.mangohud.enable = true;

  # ── Controller / Hardware Support ────────────────────────────────────────────
  # Installs udev rules for common gaming controllers (Xbox, DualShock,
  # DualSense, Steam Controller, Switch Pro). Required for some controllers
  # to be recognized without running Steam as root.
  hardware.steam-hardware.enable = true;

  # ── Gaming Packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # ProtonUp-Qt — GUI tool for installing and managing Proton-GE and other
    # Steam compatibility tool versions (Wine-GE, Luxtorpeda, etc).
    # protonup-qt

    # Heroic Games Launcher — open source launcher for Epic Games Store and
    # GOG games, with Proton/Wine support built in.
    # heroic

    # Lutris — open gaming platform that manages Wine prefixes and install
    # scripts for a wide range of non-Steam games and launchers.
    # lutris
  ];
}
