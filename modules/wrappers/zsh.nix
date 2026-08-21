{
  flake.wrappers.zsh =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.zsh ];

      zshAliases = {
        t = "tree";
        v = "nvim";
      };

      env = {
        EDITOR = "nvim";
        BROWSER = "firefox";
        COLORTERM = "truecolor";
      };

      zshrc.content = ''
        autoload -Uz compinit
        compinit

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        eval "$(starship init zsh)"

        # NixOS hosts rebuild the system; everywhere else (e.g. the Ubuntu
        # home profile) just upgrades the user's own Nix profile.
        update() {
          if [ -f /etc/NIXOS ]; then
            sudo nixos-rebuild switch --flake="$HOME/repos/infra"
          else
            nix profile upgrade --all
          fi
        }
      '';
    };
}
