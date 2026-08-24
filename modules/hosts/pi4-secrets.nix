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

      # neededForUsers alone wasn't enough (still confirmed live): under the
      # default mutableUsers = true, hashedPasswordFile only ever applies
      # the *first* time an account is created -- and root always
      # pre-exists, so it was never actually "created" from NixOS's point
      # of view, meaning it would never take effect regardless of ordering.
      # false makes it enforced on every activation instead. Safe here:
      # this host has no other interactive users, and root already has
      # both a password and an SSH key, satisfying the module's own
      # lockout-prevention assertion.
      users.mutableUsers = false;
    };
}
