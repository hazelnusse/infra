{
  flake.modules.nixos.base =
    { lib, pkgs, ... }:
    {
      # Priority strictly between lib.mkDefault (1000) and nixpkgs' own
      # boot.kernelPackages base default (mkOptionDefault, 1500): weaker
      # than mkDefault so a hardware-specific module -- e.g.
      # nixos-hardware's raspberry-pi-4, which sets its own kernelPackages
      # via mkDefault -- can still override this without a
      # conflicting-definitions error, but stronger than nixpkgs' own
      # 1500-priority default so it still wins on hosts with no
      # hardware-specific override. A plain assignment (priority 100)
      # would instead win over mkDefault, silently defeating hardware-
      # tuned kernel choices; 1500 collides outright with nixpkgs' own
      # default.
      boot.kernelPackages = lib.mkOverride 1200 pkgs.linuxPackages_latest;
    };
}
