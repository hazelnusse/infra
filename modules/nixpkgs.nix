{
  flake.modules.nixos.base = {
    home-manager.useGlobalPkgs = true;
    nixpkgs.config.allowUnfree = true;
  };
}
