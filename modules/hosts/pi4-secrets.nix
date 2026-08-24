{
  configurations.nixos.pi4.module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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

      # Sets the Pi-hole admin password on every boot from a sops-managed
      # plaintext secret. Pi-hole 6 hashes passwords with Balloon
      # hashing, and there's no exposed tool to precompute that hash
      # ourselves outside of FTL -- it only computes it internally as
      # part of *writing* the config (confirmed via FTL's own --help).
      # So we store the plaintext (sops-encrypted at rest, decrypted
      # only to tmpfs at boot) and let FTL's own API do the hashing, the
      # same way pihole-ftl-setup already authenticates and mutates
      # state for blocklists via LoginAPI/api.sh -- reused here rather
      # than reimplemented. environment.etc regenerates pihole.toml from
      # scratch on every switch (no password baked into the store), so
      # this has to reapply every boot; idempotent, same pattern as the
      # existing addList calls.
      systemd.services.pihole-ftl-setup.serviceConfig.ExecStartPost =
        let
          pihole = config.services.pihole-ftl.piholePackage;
          setAdminPassword = pkgs.writeShellScript "set-pihole-admin-password" ''
            # -u deliberately omitted: api.sh (sourced below) isn't -u-safe,
            # e.g. LoginAPI checks `[ -z "''${API_URL}" ]` before it's ever
            # set -- matches upstream's own setup script, which explicitly
            # does `set +u` before sourcing the same file, for the same
            # reason (confirmed live: this blew up with "API_URL: unbound
            # variable" before dropping -u here).
            set -eo pipefail
            # shellcheck disable=SC1091
            source ${pihole}/share/pihole/advanced/Scripts/api.sh
            for _ in 1 2 3; do
              (TestAPIAvailability) && break
              sleep .5
            done
            LoginAPI
            password="$(cat ${config.sops.secrets.pihole-admin-password.path})"
            payload="$(${lib.getExe pkgs.jq} -n --arg pw "$password" '{config:{webserver:{api:{password:$pw}}}}')"
            ${lib.getExe pkgs.curl} -skS -X PATCH "''${API_URL}config/webserver/api/password" \
              --data-raw "$payload" -H "Accept: application/json" -H "sid: ''${SID}"
          '';
        in
        [ "${setAdminPassword}" ];

      # pihole-ftl-setup.service runs as User=pihole/Group=pihole (confirmed
      # live via `systemctl show`), but sops-nix's default secret ownership
      # is root:root mode 0400 -- the script's `cat` above failed with
      # "Permission denied" until this was added (group defaults to
      # pihole's own primary group automatically once owner is set).
      sops.secrets.pihole-admin-password.owner = "pihole";
    };
}
