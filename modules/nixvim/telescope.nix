{
  flake.modules.nixvim.base = {
    plugins.telescope.enable = true;

    keymaps = [
      {
        key = "<leader>sf";
        mode = "n";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Search files";
      }
      {
        key = "<leader>sg";
        mode = "n";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Search by grep";
      }
      {
        key = "<leader>sb";
        mode = "n";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "Search buffers";
      }
      {
        key = "<leader>sh";
        mode = "n";
        action = "<cmd>Telescope help_tags<CR>";
        options.desc = "Search help";
      }
    ];
  };
}
