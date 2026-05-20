{
  flake.modules.nixos.base = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.luke = {
      isNormalUser = true;
      description = "Luke Peterson";
      extraGroups = [ "wheel" ];
    };
  };
}
