{
  flake.modules.nixvim.base = {
    lsp.servers.clangd.enable = true;

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
