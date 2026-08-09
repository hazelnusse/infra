{
  inputs,
  lib,
  withSystem,
  ...
}:
{
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule (nixosSubmoduleArgs: {
        options.system = lib.mkOption { type = lib.types.str; };
        config.module = {
          nixpkgs.pkgs = withSystem nixosSubmoduleArgs.config.system (lib.getAttr "pkgs");
        };
      })
    );
  };
  config = {
    flake.modules.nixos.base = nixosArgs: {
      home-manager.useGlobalPkgs = true;
    };
    perSystem = { system, ... }: {
      imports = [ "${inputs.nixpkgs}/nixos/modules/misc/nixpkgs.nix" ];
      nixpkgs.hostPlatform = { inherit system; };
    };
  };
}
