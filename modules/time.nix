{ lib, ... }:
{
  flake.modules.nixos.base = {
    # time.timeZone = "America/Los_Angeles";
    services = {
      ntpd-rs = {
        enable = true;
        settings.observability.log-level = "warn";
      };
      automatic-timezoned.enable = true;

      # https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-1484030107
      geoclue2.enableDemoAgent = lib.mkForce true;
    };
  };
}
