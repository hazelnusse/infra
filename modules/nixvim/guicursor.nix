{
  flake.modules.nixvim.base = {
    # nvim's cursor-shape (DECSCUSR) escape codes don't survive the
    # tmux+alacritty round-trip intact -- they leak as visible garbage
    # (e.g. a literal "E[2 q") instead of being interpreted, the same
    # class of bug already hit with zsh-vi-mode's cursor codes (see
    # ZVM_CURSOR_STYLE_ENABLED in modules/wrappers/tmux.nix). tmux's
    # "cstyle" feature and terminal-overrides are correctly configured
    # and match tmux's own built-in cstyle capability strings exactly,
    # so this isn't a missing-config problem -- disabling the codes at
    # the source is the only fix that's actually worked for this bug.
    opts.guicursor = "";
  };
}
