{
  flake.modules.homeManager.legacy =
    homeArgs@{ pkgs, ... }:
    {
      # TODO: change this to avoid the following warning:
      # evaluation warning: luke profile: You have set either `nixpkgs.config` or `nixpkgs.overlays` while using `home-manager.useGlobalPkgs`.
      # This will soon not be possible. Please remove all `nixpkgs` options when using `home-manager.useGlobalPkgs`.
      # Definitions found in `/nix/store/vfs99z7lswapf9lbj34qrygkdawirghk-source/modules/home-manager/home.nix, via option flake.modules.homeManager.legacy'.
      nixpkgs.config.allowUnfree = true;

      dconf.settings = {
        "org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };
        "org/gnome/system/location" = {
          enabled = true;
        };
      };

      fonts.fontconfig.enable = true;
      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      home.username = "luke";
      home.homeDirectory = "/home/luke";

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.

      # The home.packages option allows you to install Nix packages into your
      # environment.
      home.packages = with pkgs; [
        alacritty
        #bitwarden-desktop
        #canon-cups-ufr2
        clang
        fd
        firefox
        git
        gh
        #google-chrome
        htop
        gnumake
        gnome-tweaks
        nerd-fonts.jetbrains-mono
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji
        pinta
        ripgrep
        #telegram-desktop
        tmux
        tree
        #unzip
        xclip
        ledger-live-desktop
        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')
      ];

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      home.file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
      };

      # Home Manager can also manage your environment variables through
      # 'home.sessionVariables'. These will be explicitly sourced when using a
      # shell provided by Home Manager. If you don't want to manage your shell
      # through Home Manager then you have to manually source 'hm-session-vars.sh'
      # located at either
      #
      #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  /etc/profiles/per-user/luke/etc/profile.d/hm-session-vars.sh
      #
      home.sessionVariables = {
        EDITOR = "$(readlink -f ~/.config/nixCats-nvim/result/bin/nixCats)";
        BROWSER = "firefox";
      };

      home.sessionPath = [
        "$HOME/.config/nixCats-nvim/result/bin"
      ];

      home.shellAliases = {
        t = "tree";
        v = "$(readlink -f ~/.config/nixCats-nvim/result/bin/nixCats)";
        update = "home-manager switch";
      };

      # Enabling the shell is required to ensure home.shellAliases work
      programs.bash.enable = true;

      #programs.nixvim = {
      #  enable = true;
      #  colorschemes.catppuccin.enable = true;
      #  #plugins.lualine.enable = true;
      #};

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
        #oh-my-zsh = {
        #  enable = true;
        #  plugins = [ "git" "thefuck" ];
        #  theme = "robbyrussell";
        #};
      };

      programs.starship.enable = true;
      programs.eza.enable = true;

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
}
