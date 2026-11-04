{
  flake.modules.nixos.pihole =
    { lib, pkgs, ... }:
    {
      services.pihole-ftl = {
        enable = true;
        openFirewallDNS = true;
        openFirewallWebserver = true;
        settings.dns.queryLogging = false;
        settings.dns.upstreams = [
          "9.9.9.9" # Quad9
          "1.1.1.1" # Cloudflare
          "8.8.8.8" # Google
          "1.0.0.1" # Cloudflare (secondary)
        ];
        # Upstream defaults this to true "to prevent config changes via
        # API or CLI" -- a deliberate, application-level guard rail,
        # independent of and in addition to the environment.etc file
        # permissions below (confirmed live: with readOnly=true, even a
        # writable file was refused outright; both have to allow it).
        # We want the admin password settable via the API (see
        # modules/hosts/pi4-secrets.nix), so this has to be off.
        settings.misc.readOnly = false;
        lists = [
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            description = "Steven Black's unified adlist";
          }
        ];
      };

      services.pihole-web = {
        enable = true;
        ports = [ 80 ];
      };

      # Matches settings.misc.readOnly above: environment.etc's own
      # mode = "400" default means pihole:pihole (FTL's own user) has no
      # write bit at all, even as the file's owner -- confirmed live,
      # this alone was also sufficient to block the API from persisting
      # any change, independent of readOnly.
      environment.etc."pihole/pihole.toml".mode = lib.mkForce "600";

      # Upstream's pihole-ftl-setup script only signals FTL to reload
      # gravity.db in the "database doesn't exist yet" branch -- the
      # normal "refresh gravity on every boot" path at the end (`pihole
      # -g`) rebuilds the database but never tells the already-running
      # FTL daemon to pick it up, so blocking silently goes stale on
      # every reboot until something restarts pihole-ftl (confirmed
      # live: doubleclick.net resolved to a real IP after a reboot,
      # despite gravity having rebuilt successfully with fresh domains;
      # a plain `systemctl restart pihole-ftl` fixed it instantly).
      # This replicates the same SIGRTMIN reload signal upstream already
      # uses for the other case, unconditionally after every setup run.
      #
      # A second ExecStartPost (setting the admin password from a sops
      # secret) lives in modules/hosts/pi4-secrets.nix instead of here --
      # this group is also imported standalone by the pihole-dns VM
      # test, which has no sops.defaultSopsFile, so a secret dependency
      # can't live in the generic group itself. NixOS merges list-typed
      # options like ExecStartPost automatically, so the two entries
      # compose fine despite living in different files.
      systemd.services.pihole-ftl-setup.serviceConfig.ExecStartPost =
        let
          reloadFtl = pkgs.writeShellScript "reload-pihole-ftl" ''
            set -euo pipefail
            pid="$(systemctl show --property MainPID --value pihole-ftl.service)"
            kill -s SIGRTMIN "$pid"
          '';
        in
        [ "${reloadFtl}" ];
    };
}
