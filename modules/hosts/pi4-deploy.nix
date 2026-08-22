{
  perSystem =
    { pkgs, ... }:
    {
      # Builds from the local checkout (like `update` does for every other
      # host) and deploys to pi4 over SSH -- run from p14s-personal, which
      # has boot.binfmt.emulatedSystems set up to build aarch64-linux.
      packages.deploy-pi4 = pkgs.writeShellApplication {
        name = "deploy-pi4";
        runtimeInputs = [ pkgs.nixos-rebuild ];
        text = ''
          target="''${1:-root@192.168.50.234}"
          nixos-rebuild switch --flake "$HOME/repos/infra#pi4" --target-host "$target"
        '';
      };
    };
}
