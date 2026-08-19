{
  flake.wrappers.zsh =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.zsh ];

      zshAliases = {
        t = "tree";
        v = "nvim";
        update = "sudo nixos-rebuild switch --flake=$HOME/repos/infra";
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
      '';
    };
}
