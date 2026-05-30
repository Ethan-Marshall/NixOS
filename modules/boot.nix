# modules/boot.nix — bootloader, kernel, initrd, LUKS, and TPM2
#
# Everything that runs before your desktop session is declared here.
# Changes to this file take effect on the next `nixos-rebuild switch`
# but most only become active after a reboot.

{ pkgs, ... }:
{
  # ── Bootloader ──────────────────────────────────────────────────────────────
  # systemd-boot is a simple UEFI boot manager stored in the EFI system
  # partition. It is recommended over GRUB for modern UEFI systems — lighter,
  # faster, and works well with NixOS generations.
  boot.loader.systemd-boot.enable = true;
  # Allows NixOS to write boot entries to the EFI variables in firmware.
  # Required for systemd-boot to manage boot entries correctly.
  boot.loader.efi.canTouchEfiVariables = true;
  # Limit boot menu to the 10 most recent NixOS generations. Without this,
  # every rebuild adds a new entry and the menu grows forever.
  boot.loader.systemd-boot.configurationLimit = 10;

  # ── Kernel ──────────────────────────────────────────────────────────────────
  # linuxPackages_latest tracks the latest stable upstream kernel. This gives
  # you the newest hardware support and security patches. The tradeoff is that
  # kernel upgrades happen more frequently than with a pinned LTS kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Suppress kernel and udev messages during boot for a clean splash screen.
  # consoleLogLevel = 0 silences the kernel ring buffer output on the console.
  boot.consoleLogLevel = 0;

  # Kernel parameters passed on the kernel command line at boot:
  #   quiet           — suppress most boot messages (pairs with consoleLogLevel)
  #   nowatchdog      — disable software watchdog (avoids unexpected reboots)
  #   nmi_watchdog=0  — disable NMI (Non-Maskable Interrupt) watchdog
  #   udev.log_level=0 — suppress udev device messages during boot
  #   acpi=force      — force ACPI on even if the firmware reports issues;
  #                     helps with power management on some ThinkPads
  boot.kernelParams = [
    "quiet"
    "nowatchdog"
    "nmi_watchdog=0"
    "udev.log_level=0"
    "acpi=force"
  ];

  # ── initrd (Initial RAM Disk) ────────────────────────────────────────────────
  # The initrd is a minimal temporary root filesystem loaded into memory at
  # boot, before your real root filesystem is mounted. It handles early tasks
  # like unlocking LUKS encrypted drives.
  #
  # Using the systemd-based initrd (stage 1) instead of the legacy shell-script
  # based one. The systemd initrd is more featureful and required for TPM2.
  boot.initrd.systemd.enable = true;
  # Suppress initrd's own boot messages for a quiet boot experience.
  boot.initrd.verbose = false;
  # Enable TPM2 support in the initrd so the LUKS drives can be auto-unlocked
  # by the TPM chip on boot (see enrollment command below).
  boot.initrd.systemd.tpm2.enable = true;

  # TPM2 auto-unlock: after enrolling, the TPM will automatically supply the
  # LUKS decryption key at boot if PCRs 0 (firmware) and 7 (secure boot state)
  # match — meaning the system hasn't been tampered with. To enroll, run once:
  #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p2
  #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p3

  # ── LUKS Encrypted Volume ────────────────────────────────────────────────────
  # Tells the initrd to unlock this LUKS-encrypted partition during boot.
  # The UUID matches the specific partition on your drive. The initrd will
  # prompt for a passphrase (or use TPM2 if enrolled above) before mounting.
  boot.initrd.luks.devices."luks-7e1e369d-50ef-44e9-9902-a690579591d3".device =
    "/dev/disk/by-uuid/7e1e369d-50ef-44e9-9902-a690579591d3";

  # ── Temporary Files ──────────────────────────────────────────────────────────
  # Wipes /tmp on every boot. /tmp is meant for ephemeral files and this keeps
  # it from accumulating stale data across reboots. Also used by the fish shell
  # greeting script to detect a fresh boot vs a new terminal session.
  boot.tmp.cleanOnBoot = true;
}
