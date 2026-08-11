{
  flake.modules.nixvim.base = {
    plugins.trouble.enable = true;

    keymaps = [
      {
        key = "<leader>xx";
        mode = "n";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.desc = "Diagnostics";
      }
      {
        key = "<leader>xX";
        mode = "n";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        options.desc = "Buffer diagnostics";
      }
      {
        key = "<leader>xs";
        mode = "n";
        action = "<cmd>Trouble symbols toggle focus=false<CR>";
        options.desc = "Symbols";
      }
      {
        key = "<leader>xl";
        mode = "n";
        action = "<cmd>Trouble lsp toggle focus=false<CR>";
        options.desc = "LSP references/definitions";
      }
      {
        key = "<leader>xq";
        mode = "n";
        action = "<cmd>Trouble qflist toggle<CR>";
        options.desc = "Quickfix list";
      }
    ];

    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>x";
        group = "Trouble";
      }
    ];
  };
}
