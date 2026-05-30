# modules/symlinks.nix — dotfile symlinks via NixOS activation scripts
#
# WHY THIS APPROACH:
# NixOS manages /etc declaratively but leaves ~/.config alone by default.
# Rather than copying dotfiles, we symlink them from /etc/nixos/dotfiles/
# into their expected locations under ~/.config. This means editing a dotfile
# in /etc/nixos/dotfiles/ takes effect immediately (the symlink always points
# to the live source), and the dotfiles stay version-controlled alongside
# the NixOS config in the same repo.
#
# HOW ACTIVATION SCRIPTS WORK:
# `system.activationScripts` runs shell snippets as root during
# `nixos-rebuild switch`, after the new system is built but before it becomes
# active. This is the right place for imperative setup steps that NixOS can't
# express declaratively (like creating symlinks into a user's home directory).
#
# WHY WE `rm -rf` FIRST:
# `ln -sfn` updates an existing symlink but fails if the target is a real
# directory. The rm ensures each path is clear before relinking, so rebuilds
# are always idempotent — safe to run multiple times with the same result.
#
# NOTE: A more "Nix-native" approach would use Home Manager's
# `home.file` options to manage these declaratively. Worth exploring
# as I get more comfortable with NixOS.

{ ... }:
{
  system.activationScripts.dotfileSymlinks = {
    text = ''
      # ── Remove stale targets ────────────────────────────────────────────────
      # Clear existing directories/files/symlinks at each target location.
      # This ensures a clean slate before creating the new symlinks below.
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

      # ── Create symlinks ─────────────────────────────────────────────────────
      # ln flags:
      #   -s  create a symbolic (soft) link, not a hard link
      #   -f  force — remove the destination if it already exists
      #   -n  treat the destination as a normal file if it is a symlink to a dir
      #       (prevents creating a link inside the existing symlinked directory)
      ln -sfn /etc/nixos/dotfiles/niri              /home/ethan/.config/niri
      ln -sfn /etc/nixos/dotfiles/noctaliaV5        /home/ethan/.config/noctalia
      ln -sfn /etc/nixos/dotfiles/ghostty           /home/ethan/.config/ghostty
      ln -sfn /etc/nixos/dotfiles/fastfetch         /home/ethan/.config/fastfetch
      ln -sfn /etc/nixos/dotfiles/btop              /home/ethan/.config/btop
      ln -sfn /etc/nixos/dotfiles/fish              /home/ethan/.config/fish
      ln -sfn /etc/nixos/dotfiles/starship/starship.toml /home/ethan/.config/starship.toml
      ln -sfn /etc/nixos/dotfiles/nemo/actions      /home/ethan/.local/share/nemo/actions
      ln -sfn /etc/nixos/dotfiles/nemo/scripts      /home/ethan/.local/share/nemo/scripts
      ln -sfn /etc/nixos/dotfiles/yazi              /home/ethan/.config/yazi
      ln -sfn /etc/nixos/dotfiles/GTK/gtk-3.0       /home/ethan/.config/gtk-3.0
      ln -sfn /etc/nixos/dotfiles/GTK/gtk-4.0       /home/ethan/.config/gtk-4.0
      ln -sfn /etc/nixos/dotfiles/GTK/xsettingsd    /home/ethan/.config/xsettingsd
      ln -sfn /etc/nixos/dotfiles/GTK/.gtkrc-2.0    /home/ethan/.gtkrc-2.0
    '';
  };
}
