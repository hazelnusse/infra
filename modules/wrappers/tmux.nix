{
  flake.wrappers.tmux =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.tmux ];
      prefix = "C-a";
      mouse = true;
      terminal = "tmux-256color";
      # "tmux-256color"'s terminfo entry doesn't declare cursor-shape
      # capabilities (Ss/Se) by default; without this, any program's
      # (nvim, etc.) cursor-shape escape codes render as stray glyphs.
      terminalOverrides = ",*:Ss=\\E[%p1%d q:Se=\\E[2 q";
      modeKeys = "vi";
      vimVisualKeys = true;
      configAfter = "set -g focus-events on";
      # zsh-vi-mode reads this to skip its cursor-shape codes. Must be
      # set here, not in the zsh wrapper's env -- tmux panes don't
      # inherit that, only tmux's own environment table.
      setEnvironment.ZVM_CURSOR_STYLE_ENABLED = "false";
      plugins = [
        pkgs.tmuxPlugins.yank
        pkgs.tmuxPlugins.resurrect
        {
          plugin = pkgs.tmuxPlugins.continuum;
          configBefore = "set -g @continuum-restore 'on'";
        }
      ];
    };
}
