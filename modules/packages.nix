# modules/packages.nix — system-wide package list
#
# environment.systemPackages installs packages into the global system PATH,
# making them available to all users. For packages only you need, prefer
# home.packages in the Home Manager block in configuration.nix instead —
# it keeps the system profile smaller and changes don't require sudo.
#
# After adding or removing a package here, run:
#   sudo nixos-rebuild switch
#
# To search for packages: https://search.nixos.org/packages
# Or from the terminal: nix search nixpkgs <name>

{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [

    # ── Terminals ────────────────────────────────────────────────────────────
    ghostty    # primary terminal emulator
    # Keep alacritty installed — Niri's default config references it for the
    # built-in terminal keybind. If you break Niri's config and can't open
    # Ghostty, alacritty is your fallback way back in.
    alacritty

    # ── Editors ──────────────────────────────────────────────────────────────
    neovim     # terminal text editor
    vscodium   # VS Code without Microsoft telemetry (open source build)

    # ── Shell Utilities ───────────────────────────────────────────────────────
    wget       # command-line file downloader
    fastfetch  # system info display (used in fish greeting)
    btop       # interactive resource monitor (CPU, RAM, disk, network)
    starship   # cross-shell prompt (configured via dotfiles/starship/)
    yazi       # terminal file manager with image preview support
    efibootmgr # manage EFI boot entries from the command line
    ffmpeg     # multimedia transcoding, used by various apps as a backend
    tpm2-tss   # TPM2 Software Stack — userspace tools for TPM2 interaction

    # ── Version Control / Dev ─────────────────────────────────────────────────
    gh             # GitHub CLI — create PRs, manage issues, auth, etc.
    github-desktop # GUI GitHub client for visual diff and branch management

    # ── File Manager ─────────────────────────────────────────────────────────
    nemo               # GTK file manager (Cinnamon's file manager, runs standalone)
    nemo-fileroller    # adds right-click compress/extract to Nemo via File Roller
    ffmpegthumbnailer  # generates video thumbnails for Nemo's icon view
    evince             # document viewer (PDF, PostScript) for Nemo previews

    # ── Media ─────────────────────────────────────────────────────────────────
    vlc        # video player; also used as a target for CVE research
    mpvpaper   # uses mpv to play video files as animated wallpapers

    # ── Office / Graphics ─────────────────────────────────────────────────────
    libreoffice  # open source office suite (Writer, Calc, Impress, etc.)
    gimp         # raster image editor

    # ── Communications ────────────────────────────────────────────────────────
    protonmail-desktop # Protons E2E encrypted email client

    # ── Theming ───────────────────────────────────────────────────────────────
    qt6Packages.qt6ct  # Qt6 appearance configuration tool (for Qt app theming)
    gtk3               # GTK3 runtime library (required by GTK3 apps)
    dracula-theme      # dark Dracula color scheme for GTK apps
    papirus-icon-theme # icon theme used across the desktop
    bibata-cursors     # custom cursor theme
    nwg-look           # GTK settings GUI for Wayland (replaces lxappearance)

    # ── Browser ───────────────────────────────────────────────────────────────
    # Zen Browser is not in nixpkgs, so it comes directly from its flake input.
    # `pkgs.stdenv.hostPlatform.system` resolves to "x86_64-linux" on your machine,
    # which selects the correct pre-built binary for your architecture.
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

  ];
}
