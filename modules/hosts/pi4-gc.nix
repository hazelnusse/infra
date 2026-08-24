{
  configurations.nixos.pi4.module = {
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 14d";

    boot.loader.generic-extlinux-compatible.configurationLimit = 5;

    services.journald.extraConfig = ''
      SystemMaxUse=200M
    '';
  };
}
