{
  flake.modules.nixvim.base = {
    # Without this, plain y/d/p only touch vim's own internal register --
    # completely separate from X11, not even PRIMARY. unnamedplus makes
    # them sync with the CLIPBOARD selection specifically (the one
    # Ctrl+C/Ctrl+V and most GUI apps' copy buttons actually use), so
    # yanking in nvim and pasting elsewhere (or vice versa) just works
    # without needing "+y/"+p. Needs a clipboard provider on PATH
    # (xclip, already in packageSets.pc) to actually reach X11.
    opts.clipboard = "unnamedplus";
  };
}
