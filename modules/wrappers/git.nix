{
  flake.wrappers.git =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.git ];
      settings = {
        user.name = "Luke Peterson";
        user.email = "hazelnusse@gmail.com";
        init.defaultBranch = "main";
      };
    };
}
