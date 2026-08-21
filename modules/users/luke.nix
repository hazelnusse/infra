{ config, ... }:
{
  flake.modules.nixos.base = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.username} = {
      isNormalUser = true;
      description = "Luke Peterson";
      extraGroups = [ "wheel" ];
    };
  };
}
