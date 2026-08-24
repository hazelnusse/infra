{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      packages.homeProfile = pkgs.buildEnv {
        name = "home-profile";
        paths = (lib.remove config.packages.zsh (config.packageSets.base ++ config.packageSets.pc)) ++ [
          config.packages.zsh-work
        ];
      };
    };
}
