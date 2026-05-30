# modules/desktop.nix — display server, compositor, login manager
#
# This module configures everything between the kernel and your desktop
# session: how the screen is initialized, how you log in, and which
# compositor manages your windows.

{ ... }:
{
  # ── X11 / Wayland Foundation ────────────────────────────────────────────────
  # Even on a pure Wayland setup, enabling xserver is still needed on NixOS
  # because it provides the input driver infrastructure (libinput, xkb) that
  # Wayland compositors like Niri depend on.
  services.xserver.enable = true;

  # XWayland is a compatibility layer that runs legacy X11 applications inside
  # a Wayland session. Many apps (Electron, some games, Wine) still require it.
  programs.xwayland.enable = true;

  # Set keyboard layout for both X11 and Wayland (xkb is shared).
  # variant = "" means the default US layout with no variant (e.g. not Dvorak).
  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  # ── Niri Compositor ─────────────────────────────────────────────────────────
  # Niri is a scrollable-tiling Wayland compositor. Enabling it here installs
  # the binary and registers it as an available Wayland session with SDDM.
  # Your actual Niri config lives in dotfiles/niri/ and is symlinked by
  # modules/symlinks.nix at activation time.
  programs.niri.enable = true;

  # ── SDDM Display Manager ─────────────────────────────────────────────────────
  # SDDM (Simple Desktop Display Manager) is the login screen that starts
  # before your session. It handles session selection, user auth, and launching
  # the compositor.
  services.displayManager.sddm.enable = true;
  # Run SDDM itself under Wayland rather than X11. This is required for a
  # fully Wayland-native login experience and avoids an X11 flash at login.
  services.displayManager.sddm.wayland.enable = true;
  # Sets the default session SDDM will select on the login screen.
  # "niri" matches the session name registered by programs.niri.enable above.
  services.displayManager.defaultSession = "niri";

  # ── Auto Login ───────────────────────────────────────────────────────────────
  # Skips the SDDM login screen and boots directly into ethan's session.
  # Convenient on a single-user machine with LUKS full-disk encryption, since
  # the drive is already unlocked at boot — the login screen adds little security
  # when you're the only user on an encrypted disk.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ethan";
}
