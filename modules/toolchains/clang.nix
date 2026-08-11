{
  flake.modules.nixvim.base = {
    lsp.servers.clangd.enable = true;

    plugins.clangd-extensions.enable = true;

    keymaps = [
      {
        key = "<leader>ch";
        mode = "n";
        action = "<cmd>ClangdSwitchSourceHeader<CR>";
        options.desc = "Switch source/header";
      }
      {
        key = "<leader>cs";
        mode = "n";
        action = "<cmd>ClangdSymbolInfo<CR>";
        options.desc = "Symbol info";
      }
      {
        key = "<leader>ct";
        mode = "n";
        action = "<cmd>ClangdTypeHierarchy<CR>";
        options.desc = "Type hierarchy";
      }
      {
        key = "<leader>ca";
        mode = "n";
        action = "<cmd>ClangdAST<CR>";
        options.desc = "Show AST";
      }
    ];

    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>c";
        group = "Clangd";
      }
    ];

    # rainbow-delimiters' bundled cpp query doesn't cover [[attribute]] brackets
    # (attribute_declaration), so extend it to nest-color those too.
    extraFiles."after/queries/cpp/rainbow-delimiters.scm".text = ''
      ; extends

      (attribute_declaration
        "[[" @delimiter
        "]]" @delimiter @sentinel) @container
    '';
  };
}
