# modules/spicetify.nix — Spotify theming via Spicetify
#
# Spicetify is a CLI tool that patches the Spotify client to apply custom
# themes, color schemes, and extensions. spicetify-nix wraps it as a
# Home Manager module so the entire patched Spotify install is declared here
# and rebuilt reproducibly on every `nixos-rebuild switch`.
#
# HOW THE let BLOCK WORKS:
# `let ... in { ... }` is Nix's way of defining local variables.
# `spicePkgs` is set to the spicetify-nix package set for your architecture,
# which exposes the available themes and extensions as Nix attributes.
# This lets us reference extensions and themes by name (e.g.
# spicePkgs.extensions.adblockify) rather than hardcoding strings.
#
# WHY HOME MANAGER:
# Spicetify patches the Spotify binary, which is a per-user operation.
# It lives in Home Manager rather than environment.systemPackages because
# it modifies files in the user's profile, not the system profile.

{ pkgs, inputs, ... }:
let
  # Resolve the spicetify-nix package set for this system's architecture.
  # legacyPackages is the conventional attribute used by flakes that expose
  # a large package set (like nixpkgs itself does).
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  home-manager.users.ethan = {
    # Import the spicetify Home Manager module from the flake so the
    # `programs.spicetify` option becomes available in this block.
    imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

    programs.spicetify = {
      enable = true;

      # Extensions add functionality on top of the base Spotify client.
      enabledExtensions = with spicePkgs.extensions; [
        adblockify   # blocks ads in the Spotify client
        hidePodcasts # removes podcast recommendations from the home screen
        shuffle      # adds a true shuffle button that bypasses Spotify's algorithm
      ];

      # Catppuccin is a pastel color scheme family. The "mocha" variant is the
      # darkest of the four Catppuccin flavors (latte, frappé, macchiato, mocha).
      theme       = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
