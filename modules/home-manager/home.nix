{
  flake.modules.homeManager.legacy =
    homeArgs@{ pkgs, ... }:
    {
      dconf.settings = {
        "org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };
        "org/gnome/system/location" = {
          enabled = true;
        };
      };

      fonts.fontconfig.enable = true;

      home.username = "luke";
      home.homeDirectory = "/home/luke";

      home.stateVersion = "25.11"; # Did you read the comment before changing?

      home.packages = with pkgs; [
        alacritty
        bitwarden-desktop
        canon-cups-ufr2
        clang
        claude-code
        claude-monitor
        fd
        firefox
        git
        gh
        google-chrome
        htop
        gnumake
        gnome-tweaks
        nerd-fonts.jetbrains-mono
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji
        pinta
        ripgrep
        telegram-desktop
        tree
        usbutils
        unzip
        xclip
        ledger-live-desktop
        wget
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "firefox";
      };

      home.shellAliases = {
        t = "tree";
        v = "nvim";
        update = "sudo nixos-rebuild switch --flake=$HOME/repos/infra";
      };

      # Enabling the shell is required to ensure home.shellAliases work
      programs.bash.enable = true;

      programs.git = {
        enable = true;
        settings = {
          user.name = "Luke Peterson";
          user.email = "hazelnusse@gmail.com";
          init.defaultBranch = "main";
        };
      };

      programs.zsh = {
        dotDir = "${homeArgs.config.xdg.configHome}/zsh";
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        plugins = [
          {
            name = "vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];
      };

      programs.starship.enable = true;
      programs.eza.enable = true;

      programs.tmux = {
        enable = true;
        prefix = "C-a";
      };

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
  perSystem = {
    nixpkgs.config.allowUnfreePackages = [
      "canon-cups-ufr2"
      "claude-code"
      "google-chrome"
    ];
  };
}
