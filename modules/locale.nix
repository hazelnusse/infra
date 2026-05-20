{ lib, ... }:
{
  flake.modules.nixos.base = nixosArgs: {
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (attrName: nixosArgs.config.i18n.defaultLocale);

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
