{
  flake.modules.nixos.pc = {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Ubuntu's GNOME ships Ctrl+Alt+T -> terminal out of the box; upstream
    # GNOME (what this is) doesn't, so it's wired up declaratively here
    # rather than left as a manual, easily-lost GNOME Settings tweak.
    # `media-keys`' old static `terminal` key is gone in current GNOME --
    # only a `custom-keybindings` entry works now.
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/default-applications/terminal" = {
            exec = "alacritty";
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "Terminal";
            command = "alacritty";
            binding = "<Primary><Alt>t";
          };
        };
      }
    ];
  };
}
