{
  flake.modules.nixvim.base =
    { config, ... }:
    {
      plugins.treesitter = {
        enable = true;
        grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
          bash
          c
          cpp
          css
          csv
          diff
          git_rebase
          gitcommit
          html
          javascript
          json
          latex
          lua
          markdown
          markdown_inline
          nix
          psv
          python
          regex
          rust
          toml
          tsv
          tsx
          typescript
          vim
          vimdoc
          xml
          yaml
        ];
      };
    };
}
