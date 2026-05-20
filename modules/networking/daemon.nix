{
  flake.modules.nixos.pc = {
    # TODO: look up Dawn's awesome sauce for networking
    networking.networkmanager.enable = true;
    users.users.luke.extraGroups = [ "networkmanager" ];
  };
}
