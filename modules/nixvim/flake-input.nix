{
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
    flake = false;
    # Nixvim does not support user pinning to alternative nixpkgs,
    # it should instead track the nixpkgs they perform tests with.
    # inputs.nixpkgs.follows = "nixpkgs";
  };
}
