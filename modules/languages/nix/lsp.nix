{
  flake.modules.nixvim.base = {
    plugins.lsp.servers.nixd = {
      enable = true;
      packageFallback = true;
    };
  };
}
