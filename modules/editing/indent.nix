{
  flake.modules.nixvim.base = {
    plugins.treesitter.indent = {
      enable = true;
      # nvim-treesitter's cpp/c indent queries are thin and misindent common
      # constructs (templates, member-init lists, lambdas); Neovim's built-in
      # cindent-based indent/cpp.vim is more reliable.
      disable = [
        "c"
        "cpp"
      ];
    };
  };
}
