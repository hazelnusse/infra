{ withSystem, config, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;
      users.users.${config.username}.shell = withSystem pkgs.stdenv.hostPlatform.system (
        psArgs: psArgs.config.packages.zsh
      );
    };
}
