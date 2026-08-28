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
      # tmux only recognizes clipboard/cursor-style/focus/title pass-through
      # for terminals matching xterm*/screen*/rxvt* by default, but the
      # real terminal here (alacritty) identifies itself to tmux as
      # literally "alacritty" -- matching none of those patterns. Without
      # this, tmux doesn't know cursor-shape (cstyle) requests are safe to
      # forward, and programs' (nvim, etc.) cursor-shape escape codes leak
      # through as visible garbage instead of being handled. `hyperlinks`
      # is added here too so OSC 8 links (e.g. from `claude`) survive the
      # same pass-through path.
      configAfter = ''
        set -g focus-events on
        set -as terminal-features "alacritty:clipboard:ccolour:cstyle:focus:hyperlinks:title"
      '';
      # zsh-vi-mode reads this to skip its cursor-shape codes. Must be
      # set here, not in the zsh wrapper's env -- tmux panes don't
      # inherit that, only tmux's own environment table.
      setEnvironment.ZVM_CURSOR_STYLE_ENABLED = "false";
      plugins = [
        pkgs.tmuxPlugins.yank
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          configBefore = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-processes '"~claude->claude --continue"'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          configBefore = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '1'
          '';
        }
      ];
    };
}
