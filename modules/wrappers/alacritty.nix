{
  flake.wrappers.alacritty =
    { wlib, pkgs, ... }:
    let
      catppuccinMocha = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/alacritty/f6cb5a5c2b404cdaceaff193b9c52317f62c62f7/catppuccin-mocha.toml";
        hash = "sha256-lJzvF8PsUEILgscLIuOqLqCl0n38wTKEGSvVKEtdssU=";
      };
    in
    {
      imports = [ wlib.wrapperModules.alacritty ];
      settings = {
        general.import = [ "${catppuccinMocha}" ];
        font = {
          normal.family = "JetBrainsMono Nerd Font Mono";
          size = 11;
        };
        window.padding = {
          x = 8;
          y = 8;
        };
        # Launch straight into a persistent tmux session so closing/
        # reopening alacritty never loses panes or scrollback. Resolved
        # via PATH at runtime rather than a store path, since this repo's
        # wrapped tmux (with its own baked-in tmux.conf) is always what's
        # installed system-wide (see packageSets.base in packages.nix).
        terminal.shell = {
          program = "tmux";
          args = [
            "new-session"
            "-A"
            "-s"
            "main"
          ];
        };
      };
    };
}
