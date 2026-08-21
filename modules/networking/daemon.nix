{ config, ... }:
{
  flake.modules.nixos.pc = {
    # TODO: look up Dawn's awesome sauce for networking
    networking.networkmanager.enable = true;
    users.users.${config.username}.extraGroups = [ "networkmanager" ];
  };
}
