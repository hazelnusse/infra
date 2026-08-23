{
  configurations.nixos.pi4.module =
    { config, ... }:
    {
      sops.defaultSopsFile = ../../secrets/pi4.yaml;
      sops.secrets.root-password-hash = { };

      users.users.root.hashedPasswordFile = config.sops.secrets.root-password-hash.path;
    };
}
