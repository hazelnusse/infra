{
  flake.wrappers.tmux =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.tmux ];
      prefix = "C-a";
      mouse = true;
      configAfter = "set -g focus-events on";
    };
}
