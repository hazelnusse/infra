{
  flake.wrappers.ssh =
    {
      config,
      lib,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.modules.default ];
      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              hostname = lib.mkOption { type = lib.types.str; };
              user = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
            };
          }
        );
        default = { };
      };
      config = {
        package = lib.mkDefault pkgs.openssh;
        constructFiles.sshconfig = {
          relPath = "config";
          content = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: h:
              ''
                Host ${name}
                  HostName ${h.hostname}
              ''
              + lib.optionalString (h.user != null) "  User ${h.user}\n"
            ) config.hosts
          );
        };
        flags."-F" = config.constructFiles.sshconfig.path;
        wrapperVariants.scp = { };
        hosts = {
          pi4.hostname = "192.168.50.234";
          pi4.user = "root";
          p14s-personal-wired.hostname = "192.168.50.13";
          p14s-personal-wired.user = "luke";
          p14s-personal-wifi.hostname = "192.168.50.239";
          p14s-personal-wifi.user = "luke";
          nuc.hostname = "192.168.50.61";
          nuc.user = "luke";
        };
      };
    };
}
