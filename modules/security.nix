# modules/security.nix — authentication, fingerprint, and privilege escalation
#
# This module handles how users prove their identity to the system.
# Currently covers fingerprint auth via fprintd and PAM integration.
# Future additions (sudo rules, audit logging, etc.) belong here too.

{ ... }:
{
  # ── Fingerprint Authentication ───────────────────────────────────────────────
  # fprintd is the D-Bus daemon that talks to fingerprint reader hardware.
  # Enabling it installs the service and makes fingerprint enrollment possible.
  #
  # To enroll your fingerprint for the first time, run:
  #   sudo fprintd-enroll ethan
  # Follow the prompts to scan your finger several times. After enrolling,
  # fingerprint auth will work at any PAM prompt (sudo, lock screen, etc).
  services.fprintd.enable = true;

  # ── PAM Integration ──────────────────────────────────────────────────────────
  # PAM (Pluggable Authentication Modules) is the Linux authentication framework.
  # Every program that checks passwords (sudo, login, screen lockers) uses PAM.
  # This line adds fingerprint as an accepted auth method for system-login,
  # which covers TTY logins and display manager logins.
  security.pam.services.system-login.fprintAuth = true;

  # ── Polkit ───────────────────────────────────────────────────────────────────
  # Polkit is an authorization framework that allows non-root processes to
  # request elevated privileges in a controlled way. fprintd requires it to
  # safely expose fingerprint operations over D-Bus to unprivileged processes.
  # Many desktop components (network management, power management) also rely
  # on Polkit for privilege decisions without a full sudo prompt.
  security.polkit.enable = true;
}
