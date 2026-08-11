{
  flake.modules.nixvim.base = {
    plugins.which-key = {
      enable = true;
      settings.spec = [
        {
          __unkeyed-1 = "<leader>s";
          group = "Search";
        }
      ];
    };
  };
}
