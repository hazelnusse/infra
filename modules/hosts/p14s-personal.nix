{ config, lib, ... }:
{
  # TODO: rename configuration to match hostname and filename
  configurations.nixos.p14s-personal.module =
    nixosArgs@{
      pkgs,
      ...
    }:
    {
      imports = [
        config.flake.modules.nixos.base
        config.flake.modules.nixos.efi
        config.flake.modules.nixos.pc
        (nixosArgs.modulesPath + "/installer/scan/not-detected.nix")
      ];

      # TODO: rename hostName and change the filename
      networking.hostName = "p14s-personal";

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?

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

      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
