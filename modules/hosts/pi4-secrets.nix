{
  configurations.nixos.pi4.module =
    { config, ... }:
    {
      sops.defaultSopsFile = ../../secrets/pi4.yaml;
      # Without this, the secret decrypts to /run/secrets *after* user/shadow
      # activation already ran, so hashedPasswordFile below silently never
      # takes effect (confirmed live: /run/secrets/root-password-hash had
      # the right hash, but /etc/shadow's root entry didn't match it).
      sops.secrets.root-password-hash.neededForUsers = true;

      users.users.root.hashedPasswordFile = config.sops.secrets.root-password-hash.path;
    };
}
