{ lib, ... }:
{
  options.username = lib.mkOption {
    type = lib.types.str;
    default = "luke";
    description = "Primary user account name for NixOS hosts.";
  };
}
