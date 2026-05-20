{
  flake.modules.nixos.base =
    nixosArgs@{ pkgs, ... }:
    {
      programs.zsh.enable = true;
      users.users.luke.shell = pkgs.zsh;
    };
}
