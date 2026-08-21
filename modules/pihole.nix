{
  flake.modules.nixos.pihole = {
    services.pihole-ftl = {
      enable = true;
      openFirewallDNS = true;
      openFirewallWebserver = true;
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
  };
}
