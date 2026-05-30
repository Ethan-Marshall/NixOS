{
  description = "FracturedStack NixOS configuration";

  # ── Binary Cache ────────────────────────────────────────────────────────────
  # nixConfig tells Nix to also check this extra binary cache when downloading
  # packages. Cachix is a hosted cache service — noctalia publishes pre-built
  # binaries here so you don't have to compile it from source locally.
  # The public key is used to verify the cache hasn't been tampered with.
  nixConfig = {
    extra-substituters      = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  # ── Inputs ──────────────────────────────────────────────────────────────────
  # Inputs are external flakes this config depends on. Nix pins their exact
  # versions in flake.lock so your system is reproducible — every rebuild uses
  # the same source unless you explicitly run `nix flake update`.
  #
  # `inputs.nixpkgs.follows = "nixpkgs"` on each input tells that flake to use
  # *your* nixpkgs version rather than its own, keeping everything on the same
  # package tree and avoiding duplicate downloads.
  inputs = {

    # The main NixOS package collection. nixos-unstable gives you the latest
    # packages at the cost of less stability than a versioned release channel.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager manages per-user configuration (dotfiles, user packages,
    # user services) declaratively, the same way NixOS manages the system.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia is a Wayland status bar / shell widget suite.
    noctalia = {
      # Noctalia V4 (pinned to main branch)
      # url = "github:noctalia-dev/noctalia-shell";

      # Noctalia V5 (pinned to the v5 branch)
      url = "github:noctalia-dev/noctalia-shell/v5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # spicetify-nix provides a Home Manager module for theming Spotify via
    # Spicetify. Managed as a flake so the extensions/themes stay versioned.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser is not in nixpkgs yet, so it ships as its own flake.
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  # ── Outputs ─────────────────────────────────────────────────────────────────
  # Outputs define what this flake produces. For a system config, that is a
  # nixosConfigurations attribute keyed by hostname.
  #
  # The `@ inputs` syntax captures all inputs into a single attribute set so
  # any module can receive `inputs` and reference flake packages directly
  # (e.g. inputs.zen-browser.packages.x86_64-linux.default).
  outputs = { self, nixpkgs, home-manager, noctalia, spicetify-nix, zen-browser, ... } @ inputs: {
    nixosConfigurations.FracturedStack = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # specialArgs passes extra values into every module's function arguments.
      # Without this, modules would not receive `inputs` and could not reference
      # flake packages. This is how `inputs.zen-browser` works in packages.nix.
      specialArgs = { inherit inputs; };

      # NixOS merges all modules in this list into one unified system config.
      # Order does not matter — NixOS resolves the attribute set as a whole.
      # hardware-configuration.nix is imported inside configuration.nix itself
      # since it is tightly coupled to that file.
      modules = [
        ./configuration.nix          # core identity, user, locale, misc services
        ./modules/boot.nix           # bootloader, kernel, initrd, LUKS
        ./modules/desktop.nix        # niri, SDDM, xwayland, display settings
        ./modules/packages.nix       # system-wide package list
        ./modules/fonts.nix          # font packages and fontconfig defaults
        ./modules/symlinks.nix       # dotfile symlinks via activation scripts
        ./modules/security.nix       # fprintd fingerprint auth, polkit, PAM
        ./modules/noctalia.nix       # Noctalia shell bar (flake input package)
        ./modules/spicetify.nix      # Spotify theming via Home Manager
        ./modules/gaming.nix         # Steam, Proton, controller support
        ./modules/security-tools.nix # exploit dev / CVE research toolchain
        home-manager.nixosModules.home-manager  # injects Home Manager into NixOS
      ];
    };
  };
}
