{ inputs, ... }:
{
  imports = [ inputs.nix-wrapper-modules.flakeModules.default ];
}
