# infra

[![check](https://github.com/hazelnusse/infra/actions/workflows/check.yml/badge.svg?branch=main)](https://github.com/hazelnusse/infra/actions/workflows/check.yml)

NixOS configuration, managed as a dendritic-pattern [flake-parts](https://flake.parts/) flake using [flake-file](https://github.com/vic/flake-file). User programs (git, tmux, starship, zsh) are managed via [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules), which bakes each program's config into a wrapped binary rather than writing dotfiles into `$HOME` — see `modules/wrappers/README.md`.

## Quick reference

| Task                                                 | Command                                                                      |
| ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| Build and switch to the current config               | `sudo nixos-rebuild switch --flake=.`                                        |
| Build without switching (verify a change)            | `nix build .#nixosConfigurations.p14s-personal.config.system.build.toplevel` |
| Run the test suite locally                           | `nix flake check` — see `docs/testing.md`                                    |
| Edit an encrypted secret                             | `sops edit secrets.yaml` — see `docs/secrets.md`                             |
| Regenerate `flake.nix` after adding/editing an input | `nix run .#write-flake`                                                      |
| Apply the `main` branch-protection ruleset           | `nix run .#apply-branch-ruleset`                                             |
