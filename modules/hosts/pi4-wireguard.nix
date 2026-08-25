{
  configurations.nixos.pi4.module =
    { config, ... }:
    {
      sops.secrets.wireguard-private-key = { };

      networking.wg-quick.interfaces.wg0 = {
        address = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets.wireguard-private-key.path;
        postUp = "iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o end0 -j MASQUERADE";
        postDown = "iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o end0 -j MASQUERADE";
        peers = [
          {
            # luke-work-laptop
            publicKey = "UkjxmqIWeeOPuQ9VxFZGaVaPMWDc4a0kGbEbTaXSt3k=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };

      networking.firewall.allowedUDPPorts = [ 51820 ];
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    };
}
