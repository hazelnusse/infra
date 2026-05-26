{
  config,
  nixvim,
  ...
}:
{
  perSystem =
    psArgs@{ system, ... }:
    {
      packages.nixvim =
        nixvim.evalNixvim {
          inherit system;
          modules = [ config.flake.modules.nixvim.base ];
        }
        |> (evaluation: evaluation.config.build.package);
      checks.nixvim = psArgs.config.packages.nixvim;
    };
}
