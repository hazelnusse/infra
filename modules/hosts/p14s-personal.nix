{ config, ... }:
{
  configurations.nixos.p14s-personal = {
    module =
      { modulesPath, ... }:
      {
        imports = [
          config.flake.modules.nixos.base
          config.flake.modules.nixos.x86-efi
          config.flake.modules.nixos.pc
          config.flake.modules.nixos.x86-microcode-amd
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        networking.hostName = "p14s-personal";

        # Lets this host build aarch64-linux derivations (emulated via
        # qemu-user) so pi4 can be deployed with
        # `nixos-rebuild switch --flake .#pi4 --target-host root@<pi-ip>`
        # from here instead of compiling natively on the Pi's own SD card
        # -- native builds put enough sustained write load on the card to
        # trigger a real MMC-subsystem kernel hang during the pi4 kernel
        # build (see the plan doc's Phase 5 TODO, 2026-08-22).
        boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "26.05"; # Did you read the comment?

        # Below here originally came from /etc/nixos/hardware-configuration.nix
        # TODO: investigate https://github.com/nix-community/nixos-facter or https://github.com/NixOS/nixos-hardware/
        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "thunderbolt"
          "usb_storage"
          "sd_mod"
        ];
        boot.kernelModules = [ "kvm-amd" ];

        fileSystems."/" = {
          device = "/dev/mapper/luks-250d5aab-75f6-4fa7-8621-e835482322ea";
          fsType = "ext4";
        };

        boot.initrd.luks.devices."luks-250d5aab-75f6-4fa7-8621-e835482322ea".device =
          "/dev/disk/by-uuid/250d5aab-75f6-4fa7-8621-e835482322ea";

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/CE9B-66A8";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
      };
    system = "x86_64-linux";
  };
}
