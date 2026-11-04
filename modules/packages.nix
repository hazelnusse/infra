{
  lib,
  flake-parts-lib,
  withSystem,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { lib, ... }:
    {
      options.packageSets = {
        base = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Packages installed on every host, including headless ones.";
        };
        pc = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Additional packages installed on desktop/GUI hosts.";
        };
        work = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Packages only installed on the Ubuntu work laptop's homeProfile.";
        };
      };
    }
  );

  config = {
    perSystem =
      { config, pkgs, ... }:
      let
        # TODO: drop once NixOS/nixpkgs#582594 (fabric vs invoke 3) lands.
        azure-cli-invoke2 =
          (pkgs.extend (
            final: prev: {
              pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                (pyFinal: pyPrev: {
                  invoke = pyPrev.invoke.overridePythonAttrs (old: {
                    version = "2.2.1";
                    src = pyFinal.fetchPypi {
                      inherit (old) pname;
                      version = "2.2.1";
                      hash = "sha256-UVv0m0pIkyt5sCRZA0jaIvOcSULf+ZGtH7i4uuob5wc=";
                    };
                  });
                })
              ];
            }
          )).azure-cli;
      in
      {
        nixpkgs.config.allowUnfreePackages = [
          "claude-code"
          # Only reached via p14s-personal's own systemPackages, not
          # packageSets.pc -- see the comment there. Still needed here
          # because every nixosConfiguration reuses this perSystem `pkgs`
          # (modules/nixpkgs.nix), rather than instantiating its own.
          "google-chrome"
        ];

        packageSets = {
          base = with pkgs; [
            config.packages.git
            config.packages.ssh
            config.packages.starship
            config.packages.tmux
            curl
            dmidecode
            eza
            fd
            htop
            ripgrep
            sops
            ssh-to-age
            tree
            unzip
            usbutils
          ];
          pc = with pkgs; [
            config.packages.alacritty
            config.packages.nixvim
            config.packages.zsh
            bazelisk
            bitwarden-desktop
            clang
            claude-code
            claude-monitor
            firefox
            gh
            gnome-tweaks
            gnumake
            ledger-live-desktop
            nerd-fonts.jetbrains-mono
            noto-fonts-color-emoji
            noto-fonts-monochrome-emoji
            pinta
            telegram-desktop
            wget
            xclip
          ];
          work = with pkgs; [
            config.packages.alacritty-nixgl
            config.packages.zsh-work
            azure-cli-invoke2
            jira-cli-go
            wireguard-tools
          ];
        };
      };

    flake.modules.nixos = {
      base =
        { pkgs, ... }:
        {
          environment.systemPackages = withSystem pkgs.stdenv.hostPlatform.system (
            psArgs: psArgs.config.packageSets.base
          );
        };
      pc =
        { pkgs, ... }:
        {
          environment.systemPackages = withSystem pkgs.stdenv.hostPlatform.system (
            psArgs: psArgs.config.packageSets.pc
          );
        };
    };
  };
}
