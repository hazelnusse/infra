{
  perSystem =
    { pkgs, ... }:
    {
      # Builds from the local checkout (like `update` does for every other
      # host) and deploys to pi4 over SSH -- run from p14s-personal, which
      # has boot.binfmt.emulatedSystems set up to build aarch64-linux. An
      # optional second argument builds straight from a GitHub ref instead,
      # so a PR can be tried on pi4 without touching this checkout.
      packages.deploy-pi4 = pkgs.writeShellApplication {
        name = "deploy-pi4";
        runtimeInputs = [ pkgs.nixos-rebuild ];
        text = ''
          target="''${1:-root@192.168.50.234}"
          flake="$HOME/repos/infra"
          if [ -n "''${2:-}" ]; then
            flake="github:hazelnusse/infra/$2"
          fi
          nixos-rebuild switch --flake "$flake#pi4" --target-host "$target"
        '';
      };
    };
}
