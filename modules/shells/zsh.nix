{ withSystem, config, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    let
      wrappedZsh = withSystem pkgs.stdenv.hostPlatform.system (psArgs: psArgs.config.packages.zsh);
    in
    {
      # Point programs.zsh at the wrapped package too, not just the login
      # shell -- otherwise this module's own environment.systemPackages
      # entry (plain pkgs.zsh) collides with the wrapped one, and which
      # one wins /run/current-system/sw/bin/zsh depends on accidental
      # systemPackages list ordering, not anything deterministic.
      programs.zsh = {
        enable = true;
        package = wrappedZsh;
      };
      users.users.${config.username}.shell = wrappedZsh;
    };
}
