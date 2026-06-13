{
  config,
  inputs,
  ...
}:
{
  flake.modules.nixos = {
    base = {
      imports = [ (inputs.home-manager + "/nixos") ];

      home-manager.users.luke =
        { osConfig, ... }:
        {
          home.stateVersion = osConfig.system.stateVersion;
          imports = [
            # TODO:
            config.flake.modules.homeManager.legacy
            #config.flake.modules.homeManager.base
          ];
        };
    };
    pc = {
      #home-manager.users.luke = config.flake.modules.homeManager.gui;
    };
  };
}
