{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks.vm-smoke-test = pkgs.testers.runNixOSTest {
        name = "vm-smoke-test";
        nodes.machine = { };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.succeed("echo ok")
        '';
      };

      checks.base-efi-pc-boot = pkgs.testers.runNixOSTest {
        name = "base-efi-pc-boot";
        nodes.machine = {
          imports = [
            config.flake.modules.nixos.base
            config.flake.modules.nixos.efi
            config.flake.modules.nixos.pc
          ];
          system.stateVersion = "25.11";
        };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.wait_for_unit("sshd.service")
          machine.succeed("systemctl is-system-running --wait")
        '';
      };
    };
}
