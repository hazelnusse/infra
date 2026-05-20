{
  flake.modules.nixos.pc = {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
  };
}
