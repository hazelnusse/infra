{
  perSystem =
    { pkgs, ... }:
    {
      # Builds locally and deploys to nuc over SSH -- unlike pi4, nuc is
      # native x86_64 so no boot.binfmt cross-build is needed. An optional
      # second argument builds straight from a GitHub ref instead of this
      # checkout, so a PR can be tried on nuc without touching it. nuc's
      # SSH user isn't root (see modules/wrappers/ssh.nix), hence
      # --elevate=sudo.
      packages.deploy-nuc = pkgs.writeShellApplication {
        name = "deploy-nuc";
        runtimeInputs = [ pkgs.nixos-rebuild ];
        text = ''
          target="''${1:-luke@192.168.50.61}"
          flake="$HOME/repos/infra"
          if [ -n "''${2:-}" ]; then
            flake="github:hazelnusse/infra/$2"
          fi
          nixos-rebuild switch --flake "$flake#nuc" --target-host "$target" --elevate=sudo
        '';
      };
    };
}
