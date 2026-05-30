# modules/noctalia.nix — Noctalia status bar / shell widget
#
# Noctalia is not in nixpkgs, so it is pulled directly from its flake input
# defined in flake.nix. The package is resolved per-system using
# `pkgs.stdenv.hostPlatform.system`, which evaluates to "x86_64-linux" here.
#
# The actual Noctalia configuration (widgets, layout, styling) lives in
# dotfiles/noctaliaV5/ and is symlinked to ~/.config/noctalia by symlinks.nix.
#
# Supporting services required by Noctalia (bluetooth, upower,
# power-profiles-daemon) are enabled in configuration.nix.

{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
