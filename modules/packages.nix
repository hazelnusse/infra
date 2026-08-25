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
            config.packages.nixvim
            config.packages.zsh
            alacritty
            bazelisk
            bitwarden-desktop
            canon-cups-ufr2
            clang
            claude-code
            claude-monitor
            firefox
            gh
            gnome-tweaks
            gnumake
            google-chrome
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
            config.packages.zsh-work
            azure-cli
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
