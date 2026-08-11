{
  flake.modules.nixvim.base = {
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem.follow_current_file.enabled = true;
      };
    };

    keymaps = [
      {
        key = "<leader>e";
        mode = "n";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }
    ];
  };
}
