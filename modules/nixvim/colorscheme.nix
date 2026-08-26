{
  flake.modules.nixvim.base = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        term_colors = true;
        integrations = {
          blink_cmp = true;
          gitsigns = true;
          native_lsp.enabled = true;
          neotree = true;
          telescope.enabled = true;
          treesitter = true;
          which_key = true;
        };
      };
    };
  };
}
