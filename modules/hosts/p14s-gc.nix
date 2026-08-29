{
  configurations.nixos.p14s-personal.module = {
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 14d";
  };
}
