{
  flake.modules.nixos.base = {
    boot.loader.systemd-boot.enable = true;
  };
}
