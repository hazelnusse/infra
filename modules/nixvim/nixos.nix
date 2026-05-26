{ withSystem, ... }:
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (withSystem pkgs.stdenv.hostPlatform.system (psArgs: psArgs.config.packages.nixvim))
      ];
    };
}
