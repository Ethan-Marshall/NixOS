# modules/fonts.nix — font packages and fontconfig defaults
#
# Fonts installed via NixOS modules go into the system font path and are
# available to all users and applications. Fonts installed only through
# home.packages may not be visible to system-level services or other users.
#
# fontDir.enable = true creates a standard /run/current-system/sw/share/fonts
# directory so applications that scan a fixed path can find them.
#
# fontconfig handles font discovery and selection. The defaultFonts block sets
# system-wide fallbacks for each font category, used when an app doesn't
# request a specific font.

{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      # Monaspace is a variable font superfamily from GitHub Next.
      # MonaspiceNe (Neon) is the monospace variant used as the system default.
      nerd-fonts.monaspace

      # JetBrains Mono — a clean programming font, kept as an alternative.
      nerd-fonts.jetbrains-mono

      # Geist — Vercel's sans-serif font, used as the system sans-serif default.
      geist-font

      # Emoji fonts — two are listed so there is a broad fallback.
      # Twitter Color Emoji is set as primary; Noto fills any gaps.
      twemoji-color-font
      noto-fonts-color-emoji

      # Adwaita fonts — part of the GNOME design system, needed by some GTK apps.
      adwaita-fonts
    ];

    # Creates a merged font directory in the system profile so applications
    # that scan a hardcoded path (rather than asking fontconfig) find the fonts.
    fontDir.enable = true;

    fontconfig = {
      enable = true;
      # These set the default font for each category when no specific font is
      # requested. Apps that do request a specific font ignore these defaults.
      defaultFonts = {
        # Used in terminals, code editors, and anywhere monospace is needed.
        monospace = [ "MonaspiceNe Nerd Font Mono" ];
        # Used in GTK dialogs, system UI, and apps without a specific font set.
        sansSerif = [ "Geist" ];
        # Emoji are tried in order — Twitter Color first, Noto as fallback.
        emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
      };
    };
  };
}
