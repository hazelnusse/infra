{ config, inputs, ... }:
{
  configurations.nixos.pi4 = {
    module = {
      imports = [
        config.flake.modules.nixos.base
        config.flake.modules.nixos.pihole
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];

      networking.hostName = "pi4";

      system.stateVersion = "26.05";

      hardware.facter.reportPath = ./pi4-facter.json;

      # Reusing the stock NixOS aarch64 sd-image already flashed to the SD
      # card rather than a disko install -- disko has no equivalent of the
      # sd-image builder's populateFirmwareCommands (Raspberry Pi's own
      # firmware/config.txt/u-boot.bin on a FAT partition), so a from-
      # scratch disko-based install would need that step hand-rolled. The
      # labels below match sd-image.nix's own defaults (firmwarePartitionName
      # = "FIRMWARE", rootVolumeLabel = "NIXOS_SD"), so these just take over
      # management of the partitions the stock image already created --
      # nothing is reformatted. boot.loader.generic-extlinux-compatible is
      # already enabled by the raspberry-pi-4 module above.
      fileSystems."/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [
          "nofail"
          "noauto"
        ];
      };
      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };
    system = "aarch64-linux";
  };
}
