{
  flake.modules.nixvim.base = {
    # Option 1:
    #plugins.whitespace.enable = true;
    # Option 2:
    opts = {
      list = true;
      listchars = {
        tab = "<->";
        nbsp = "␣";
        #trail = "•";
      };
    };
    # Option 3:
    plugins.mini-trailspace.enable = true;
  };
}
