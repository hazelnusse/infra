{
  config,
  ...
}:
{
  perSystem =
    psArgs@{ inputs', pkgs, ... }:
    {
      packages.nixvim = inputs'.nixvim.legacyPackages.makeNixvimWithModule {
        inherit pkgs;
        module = config.flake.modules.nixvim.base;
      };
      checks.nixvim = psArgs.config.packages.nixvim;
    };
}
