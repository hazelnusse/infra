{ withSystem, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;
      users.users.luke.shell = withSystem pkgs.stdenv.hostPlatform.system (
        psArgs: psArgs.config.packages.zsh
      );
    };
}
