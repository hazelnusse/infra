{
  perSystem =
    { config, pkgs, ... }:
    {
      packages.homeProfile = pkgs.buildEnv {
        name = "home-profile";
        paths = config.packageSets.base ++ config.packageSets.pc;
      };
    };
}
