{ config, inputs, ... }:
{
  configurations.nixos.nuc = {
    module = {
      imports = [
        config.flake.modules.nixos.base
        config.flake.modules.nixos.pc
        config.flake.modules.nixos.x86-efi
        config.flake.modules.nixos.x86-microcode-intel
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-gpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];

      networking.hostName = "nuc";

      # wlp58s0 (Intel AC 8265) is the only connection this host uses --
      # eno1 has no cable plugged in -- so this is the only path a wake
      # packet has. Confirmed via `iw list` that the firmware advertises
      # magic-packet WoWLAN support before adding this.
      networking.networkmanager.connectionConfig."wifi.wake-on-wlan" = "magic";

      system.stateVersion = "26.05";

      hardware.facter.reportPath = ./nuc-facter.json;

      # Below here originally came from /etc/nixos/hardware-configuration.nix
      # and /etc/nixos/configuration.nix on the already-installed machine --
      # adopting the existing LUKS/EFI layout, not a fresh disko install.
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/c89e0f9f-89fa-4607-905a-ed0ca4416ec2";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-030f0198-db41-4770-b16d-83d751d193e7".device =
        "/dev/disk/by-uuid/030f0198-db41-4770-b16d-83d751d193e7";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/E7C8-20C4";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      boot.initrd.luks.devices."luks-75be42cc-96b0-44e9-bc9f-d7fa10b48f43".device =
        "/dev/disk/by-uuid/75be42cc-96b0-44e9-bc9f-d7fa10b48f43";

      swapDevices = [ { device = "/dev/disk/by-uuid/7aa904ca-95e0-4252-9287-60e72f437c59"; } ];
    };
    system = "x86_64-linux";
  };
}
