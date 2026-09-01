{
  configurations.nixos.pi4.module =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.raspberrypi-eeprom.override {
          flashrom = pkgs.flashrom.overrideAttrs (_: {
            # Drop this override once flashrom's check is fixed upstream --
            # it may not be needed for future firmware updates.
            doCheck = false;
          });
        })
      ];
    };
}
