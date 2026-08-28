{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks.pihole-dns = pkgs.testers.runNixOSTest {
        name = "pihole-dns";
        nodes.machine =
          { pkgs, ... }:
          {
            imports = [
              config.flake.modules.nixos.base
              config.flake.modules.nixos.pihole
            ];
            system.stateVersion = "26.05";
            environment.systemPackages = [ pkgs.dig ];
          };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.wait_for_unit("pihole-ftl.service")
          machine.wait_for_open_port(53)

          ret, out = machine.execute("dig @localhost +short pi.hole")
          assert ret == 0, "pi.hole should resolve on the local machine"
          assert out.rstrip() == "127.0.0.1", "pi.hole should resolve to localhost"
        '';
      };
    };
}
