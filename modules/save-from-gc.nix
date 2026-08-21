topLevel@{ ... }:
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      system,
      ...
    }:
    {
      # nix flake check builds everything but leaves no lasting GC root, so
      # CI's post-job garbage collection sweeps almost all of it before the
      # cache is saved. `nix build .#saveFromGC` creates a `result` symlink
      # referencing every check and package, protecting them through to the
      # save step. See nix-community/cache-nix-action's README, "Save Nix
      # store paths from garbage collection".
      #
      # topLevel.config.flake.checks is used (not the perSystem-local
      # `config.checks`) because checks added directly via `config.flake.checks`
      # (as modules/configurations/nixos.nix does for each host's toplevel)
      # aren't transposed back into perSystem's own `config.checks` view.
      packages.saveFromGC = pkgs.linkFarm "save-from-gc" (
        lib.mapAttrsToList (name: path: { inherit name path; }) (
          (topLevel.config.flake.checks.${system} or { })
          // (lib.filterAttrs (name: _: name != "saveFromGC") config.packages)
        )
      );
    };
}
