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
    };
}
