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
      };
    }
  );

  config = {
    perSystem =
      { config, pkgs, ... }:
      {
        nixpkgs.config.allowUnfreePackages = [
          "canon-cups-ufr2"
          "claude-code"
          "google-chrome"
        ];

        packageSets = {
          base = with pkgs; [
            config.packages.git
            config.packages.starship
            config.packages.tmux
            clang
            claude-code
            claude-monitor
            eza
            fd
            gh
            gnumake
            htop
            ripgrep
            tree
            unzip
            usbutils
            wget
          ];
          pc = with pkgs; [
            config.packages.nixvim
            alacritty
            bitwarden-desktop
            canon-cups-ufr2
            firefox
            gnome-tweaks
            google-chrome
            ledger-live-desktop
            nerd-fonts.jetbrains-mono
            noto-fonts-color-emoji
            noto-fonts-monochrome-emoji
            pinta
            telegram-desktop
            xclip
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
