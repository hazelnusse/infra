{
  flake.modules.nixos.pihole =
    { pkgs, ... }:
    {
      services.pihole-ftl = {
        enable = true;
        openFirewallDNS = true;
        openFirewallWebserver = true;
        settings.dns.upstreams = [
          "1.1.1.1"
          "9.9.9.9"
        ];
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
      systemd.services.pihole-ftl-setup.serviceConfig.ExecStartPost =
        let
          reloadFtl = pkgs.writeShellScript "reload-pihole-ftl" ''
            set -euo pipefail
            pid="$(systemctl show --property MainPID --value pihole-ftl.service)"
            kill -s SIGRTMIN "$pid"
          '';
        in
        "${reloadFtl}";
    };
}
