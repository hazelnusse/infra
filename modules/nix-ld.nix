{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      # NixOS has no FHS (/bin/bash, standard dynamic linker paths), which
      # trips up prebuilt non-Nix-patched binaries -- notably the bazel
      # release bazelisk downloads at runtime (see modules/packages.nix).
      # Not needed on the non-NixOS homeProfile: a normal Linux distro
      # already has a real FHS, so this problem doesn't exist there.
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        openssl
        zlib
      ];
    };
}
