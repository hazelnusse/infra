{
  config,
  nixvim,
  ...
}:
{
  perSystem =
    psArgs@{ system, pkgs, ... }:
    {
      packages.nixvim =
        nixvim.evalNixvim {
          inherit system;
          modules = [
            # Use the same nixpkgs as the rest of the system. Comment this
            # out to fall back to nixvim's own self-pinned nixpkgs, e.g. to
            # check whether an issue is caused by an untested nixvim+nixpkgs
            # combination.
            { nixpkgs.pkgs = pkgs; }
            config.flake.modules.nixvim.base
          ];
        }
        |> (evaluation: evaluation.config.build.package);
      checks.nixvim = psArgs.config.packages.nixvim;
    };
}
