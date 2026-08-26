{
  flake.wrappers.starship =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.starship ];
      preset = "bracketed-segments";
    };
}
