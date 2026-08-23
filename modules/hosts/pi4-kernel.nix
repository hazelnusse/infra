{
  # nixos-hardware's raspberry-pi-4 module (imported in pi4.nix) sets its
  # own custom out-of-tree kernel via mkDefault -- a vendor-patched build
  # not on cache.nixos.org, so it has to actually compile (hours, even
  # emulated). The stock generic aarch64 sd-image this host was originally
  # flashed from uses NixOS's plain default kernel instead, with zero
  # nixos-hardware involvement, and that's been booting and running fine
  # on this exact hardware all along (ethernet, USB, HDMI console all
  # proven working on it). A plain assignment here (default priority)
  # beats nixos-hardware's mkDefault, so we get that same cache-
  # substitutable kernel while still keeping everything else the module
  # provides (bootloader wiring, device tree filter).
  configurations.nixos.pi4.module =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
