{ config, ... }:
{
  flake.modules.nixos.pc = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.username} = {
      isNormalUser = true;
      description = "Luke Peterson";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpSgxY5Gz86uTV5LZRyBuTaI0VAaW66oEfYX8pyteCz luke@nixos"
      ];
    };
  };
}
