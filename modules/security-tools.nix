# modules/security-tools.nix — exploit development and CVE research toolchain
#
# This module is intentionally kept separate from packages.nix so that
# security tooling changes are isolated from general package management.
# It also makes it easy to toggle the entire toolchain on or off, or
# eventually move it to a dedicated NixOS profile.
#
# SYSTEM vs HOME MANAGER FOR SECURITY TOOLS:
# Tools that need setuid/setcap wrappers or system capabilities (e.g.
# Wireshark's packet capture) must go in environment.systemPackages here.
# Tools that are pure userspace (pwntools, pwndbg, Python exploit scripts)
# are better managed in a Home Manager Python environment or a nix-shell/
# devShell so they don't pollute the global system profile.
#
# NIX-SHELL FOR LAB WORK:
# For a per-project exploit dev environment, consider a shell.nix or
# flake devShell. You can enter it with `nix-shell` or `nix develop` and
# get a sandboxed env with exactly the tools that project needs. This is
# cleaner than installing everything globally, especially for Python-based
# tools that may have conflicting dependencies.
#
# To search for a package: nix search nixpkgs <name>
# To try a package without installing: nix shell nixpkgs#<name>

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    # ── Binary Analysis / Reversing ───────────────────────────────────────────
    # radare2      # open source RE framework; CLI-driven disassembler/debugger
    # binutils     # GNU binary utilities: objdump, readelf, nm, strings, etc.
    #              # (often already present; good to declare explicitly)

    # ── Debugging ─────────────────────────────────────────────────────────────
    # gdb          # GNU debugger — baseline for Linux exploit dev
    #
    # pwndbg and GEF are GDB enhancement plugins. They are Python-based and
    # best installed via a Home Manager Python environment or a devShell
    # to avoid conflicts with other Python packages on the system profile.

    # ── Network Analysis ──────────────────────────────────────────────────────
    # wireshark    # GUI packet capture and analysis
    #              # NOTE: also uncomment the programs.wireshark block below
    #              # to grant ethan capture permissions without running as root
    # nmap         # network scanner and port discovery
    # tcpdump      # CLI packet capture

    # ── Fuzzing ───────────────────────────────────────────────────────────────
    # aflplusplus  # AFL++ coverage-guided fuzzer; useful for file parser targets

    # ── Exploit Dev / CTF ─────────────────────────────────────────────────────
    # pwntools is a Python library and is best managed in a virtual env or
    # Home Manager Python env rather than here. Example home-manager setup:
    #
    #   home.packages = [
    #     (pkgs.python3.withPackages (ps: with ps; [ pwntools ]))
    #   ];
    #
    # python3      # if you need a bare Python3 on the system path

  ];

  # ── Wireshark Capture Permissions ─────────────────────────────────────────
  # Normally packet capture requires root. Enabling programs.wireshark installs
  # a setuid-capable dumpcap binary and creates a "wireshark" group. Adding
  # ethan to that group allows capturing without sudo.
  # Uncomment both lines together when you uncomment wireshark above.
  # programs.wireshark.enable = true;
  # users.users.ethan.extraGroups = [ "wireshark" ];
}
