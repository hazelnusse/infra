{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      services.printing = {
        enable = true;
        startWhenNeeded = false;
        browsed.enable = false;
        drivers = [
          (pkgs.runCommand "canon-mf731c-ppd" { } ''
            install -Dm644 ${./ppds/canon-mf731c.ppd} $out/share/cups/model/canon-mf731c.ppd
          '')
        ];
      };

      hardware.printers = {
        ensurePrinters = [
          {
            name = "Canon_MF731C";
            description = "Canon MF731C";
            location = "Home";
            deviceUri = "ipp://192.168.50.3/ipp/print";
            model = "canon-mf731c.ppd";
          }
        ];
        ensureDefaultPrinter = "Canon_MF731C";
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
}
