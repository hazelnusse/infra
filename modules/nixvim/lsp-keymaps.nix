{
  # Neovim 0.11+ ships default LSP keymaps (grn, gra, grr, gri, grt, gO, K,
  # <C-s>, [d/]d) out of the box -- see :help lsp-defaults. This module only
  # adds what's genuinely missing from those: go-to-definition/declaration
  # and workspace symbols, backed by telescope pickers, plus an inlay hints
  # toggle.
  flake.modules.nixvim.base = {
    lsp.inlayHints.enable = true;

    plugins.lsp.keymaps.extra = [
      {
        key = "gd";
        mode = "n";
        action.__raw = "require('telescope.builtin').lsp_definitions";
        options.desc = "Goto definition";
      }
      {
        key = "gD";
        mode = "n";
        action.__raw = "vim.lsp.buf.declaration";
        options.desc = "Goto declaration";
      }
      {
        key = "gW";
        mode = "n";
        action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
        options.desc = "Workspace symbols";
      }
      {
        key = "<leader>th";
        mode = "n";
        action.__raw = ''
          function()
            local enabled = not vim.lsp.inlay_hint.is_enabled()
            vim.lsp.inlay_hint.enable(enabled)

            local message = enabled and "Inlay Hints Enabled" or "Inlay Hints Disabled"
            vim.notify(message, vim.log.levels.INFO)
          end
        '';
        options.desc = "Toggle inlay hints";
      }
    ];
  };
}
