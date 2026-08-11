{
  flake.modules.nixvim.base = {
    plugins.todo-comments = {
      enable = true;

      keymaps.todoTelescope = {
        key = "<leader>st";
        options.desc = "Search TODOs";
      };
    };

    keymaps = [
      {
        key = "]t";
        mode = "n";
        action.__raw = "function() require('todo-comments').jump_next() end";
        options.desc = "Next TODO comment";
      }
      {
        key = "[t";
        mode = "n";
        action.__raw = "function() require('todo-comments').jump_prev() end";
        options.desc = "Previous TODO comment";
      }
    ];
  };
}
