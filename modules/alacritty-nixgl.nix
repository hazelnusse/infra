{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      alacritty = lib.getExe config.packages.alacritty;
    in
    {
      # GNOME launches a terminal by spawning a real executable -- both for
      # Ctrl+Alt+T (gsd-media-keys reads the `exec` key of
      # org.gnome.desktop.default-applications.terminal) and for any .desktop
      # entry. Neither can ever see the `alacritty` shell function that
      # zsh-work defines, so the nixGL indirection has to exist as an actual
      # binary too, not just as shell-local sugar. See docs/non-nixos.md for
      # wiring it up as the session's terminal.
      packages.alacritty-nixgl = pkgs.symlinkJoin {
        name = "alacritty-nixgl";
        paths = [
          (pkgs.writeShellScriptBin "alacritty-nixgl" ''
            # nixGL is resolved at runtime rather than as a store path
            # because its build is impure and it therefore lives in its own
            # separate profile, outside this flake (see docs/non-nixos.md).
            nixgl="$HOME/.nix-profile-nixgl/bin/nixGL"
            if [ -x "$nixgl" ]; then
              exec "$nixgl" ${alacritty} "$@"
            fi
            # Falling through rather than bailing out: unwrapped alacritty
            # still works on any host whose GPU driver Nix can see by itself
            # (i.e. NixOS), and on a host where it can't the failure is the
            # ordinary "failed to find suitable GL configuration" that
            # docs/non-nixos.md already covers.
            echo "alacritty-nixgl: no nixGL at $nixgl -- see docs/non-nixos.md" >&2
            exec ${alacritty} "$@"
          '')
          # Separate from the wrapped alacritty's own Alacritty.desktop
          # (which runs it without nixGL, so its GL init fails when launched
          # from the GNOME shell) rather than replacing it -- two entries in
          # the app grid, but no filename collision when buildEnv assembles
          # homeProfile.
          (pkgs.makeDesktopItem {
            name = "alacritty-nixgl";
            desktopName = "Alacritty (nixGL)";
            genericName = "Terminal";
            comment = "Alacritty, wrapped in nixGL for a non-NixOS host's GPU driver";
            # Resolved via $PATH at runtime, not baked in as a store path:
            # the launcher is installed into the same profile as everything
            # else, and the GNOME session's $PATH already includes
            # ~/.nix-profile/bin.
            exec = "alacritty-nixgl";
            icon = "Alacritty";
            terminal = false;
            categories = [
              "System"
              "TerminalEmulator"
            ];
            # Matches the wrapped alacritty's own entry, so the window GNOME
            # ends up with is attributed to this launcher's icon.
            startupWMClass = "Alacritty";
          })
        ];
      };
    };
}
