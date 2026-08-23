{ inputs, ... }:
{
  flake-file.inputs.treefmt = {
    url = "github:numtide/treefmt-nix";
    flake = false;
  };
  imports = [ (inputs.treefmt + "/flake-module.nix") ];

  perSystem = {
    treefmt = {
      #projectRootFile = "flake.nix";
      programs = {
        prettier.enable = true;
        #shfmt.enable = true;
      };
      settings = {
        on-unmatched = "fatal";
        # nixos-facter's own output format -- not meant to be hand-formatted,
        # and reflowing it on every regeneration would just be repo noise.
        # secrets/*.yaml similarly: sops's own indentation style differs
        # from prettier's, so without this every `sops edit` would show a
        # spurious reformatting diff alongside the real content change.
        global.excludes = [
          "*-facter.json"
          "secrets/*.yaml"
        ];
      };
    };
    #pre-commit.settings.hooks.treefmt.enable = true;
  };

  flake.modules.nixvim.base = nixvimArgs: {
    plugins = {

      # To disable an lsp at runtime:
      #   * look up the lsp servers running by:
      #     :checkhealth lsp
      #   * once the filetype (e.g. nix) and name is identified (e.g., none-ls):
      #     :lua require('lsp-format').setup({nix={exclude={"null-ls"}}})
      lsp-format.enable = true;

      none-ls = {
        enable = true;
        sources.formatting.nix_flake_fmt = {
          enable = true;
          # Defaults to every filetype otherwise, running `nix fmt` even in
          # projects with no `formatter` flake output.
          settings.filetypes = [ "nix" ];
        };
      };
    };

    keymaps = [
      {
        key = "<space>f";
        mode = "n";
        action = "<cmd>Format<CR>";
      }
      {
        key = "<leader>a";
        options.desc = "Toggle lsp-format autoformatting";
        action = nixvimArgs.lib.nixvim.mkRaw ''
          function()
            local lsp_format = require("lsp-format")

            lsp_format.disabled = not lsp_format.disabled

            local message
            if lsp_format.disabled then
              message = "lsp-format autoformatting OFF"
            else
              message = "lsp-format autoformatting ON"
            end
            vim.notify(message, vim.log.levels.INFO)
          end
        '';
      }
    ];
  };
}
