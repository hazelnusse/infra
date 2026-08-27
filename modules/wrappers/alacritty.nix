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
        # Alacritty replaces its whole built-in default hint (URL regex +
        # OSC 8 hyperlinks, Ctrl+click/no-modifier-hover) the moment any
        # custom hint is configured -- so this has to restate the URL
        # matching too, not just add hyperlinks on top of it. The regex
        # is a simplified stand-in for upstream's exact byte-range
        # exclusions (impractical to reproduce verbatim here); it covers
        # real-world URLs equally well.
        hints.enabled = [
          {
            hyperlinks = true;
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\s<>\"`]+";
            post_processing = true;
            command = "xdg-open";
            # Shift is required, not just Control: Alacritty hardcodes
            # Shift as the only way to bypass a mouse-reporting-active
            # program (tmux, via its own `mouse = true`) and handle a
            # click/hover as a hint instead of forwarding it -- this
            # isn't something `mods` alone can override, so it has to
            # be part of the combo here to actually take effect.
            mouse = {
              enabled = true;
              mods = "Control|Shift";
            };
            binding = {
              key = "O";
              mods = "Control|Shift";
            };
          }
        ];
      };
    };
}
