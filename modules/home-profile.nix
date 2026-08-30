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
        paths =
          (lib.subtractLists [
            config.packages.zsh
            config.packages.ssh
          ] (config.packageSets.base ++ config.packageSets.pc))
          ++ config.packageSets.work;
      };
    };
}
