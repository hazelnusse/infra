# Wrapper modules

User programs in this repo (git, tmux, starship, zsh) are managed via
[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)
instead of home-manager. Rather than writing dotfiles into `$HOME`,
each program's config is baked into a wrapped binary at build time
(usually via an env var like `GIT_CONFIG_GLOBAL`/`STARSHIP_CONFIG`, or a
CLI flag like tmux's `-f`) — the same approach this repo already used
for `nixvim`. The wrapped binary is a plain Nix package: no per-user
activation step, no `$HOME` or username assumptions, works identically
via `environment.systemPackages` on NixOS or `nix profile install`
anywhere else.

Each `modules/wrappers/<name>.nix` file declares `flake.wrappers.<name>`,
which the library auto-builds into `packages.<system>.<name>` for every
system this flake supports.

## Adding a program not yet wrapped

Check [nix-wrapper-modules' own catalog](https://github.com/BirdeeHub/nix-wrapper-modules/tree/main/wrapperModules)
first — if the program's already there, `imports = [ wlib.wrapperModules.<name> ]`
and set its options, following the existing files in this directory as
examples. Nothing needs upstreaming to add a program locally: a module
defined in this repo works identically to one from their catalog.

If it's not there, the recipe is three pieces — this is their actual
git wrapper, trimmed slightly:

```nix
{ config, lib, wlib, pkgs, ... }:
{
  imports = [ wlib.modules.default ];
  options.settings = lib.mkOption {
    inherit (pkgs.formats.gitIni { }) type;
    default = { };
  };
  config = {
    package = lib.mkDefault pkgs.git;
    env.GIT_CONFIG_GLOBAL = config.constructFiles.gitconfig.path;
    constructFiles.gitconfig.content = lib.generators.toGitINI config.settings;
  };
}
```

1. `config.package` — the underlying program to wrap.
2. `config.constructFiles.<name>.content` — the config file's content as
   a string, generated with `lib.generators.*`/`pkgs.formats.*` for
   structured formats (TOML/YAML/INI/JSON) rather than hand-rolled.
3. Point the program at the generated file via `config.env.<VAR>` if it
   reads an env var, or `config.flags."<flag>"` if it takes a CLI flag.

`wlib` is available as a module arg automatically inside
`flake.wrappers.<name>`, same as in the library's own modules.

**When a program only reads a fixed path with no env-var or flag
override** (rare among well-behaved CLI tools): first check for
`XDG_CONFIG_HOME` support — many freedesktop-conformant apps honor it
even without a dedicated option, so `env.XDG_CONFIG_HOME` pointing at a
pre-populated directory still works. Failing that, install it as a
plain unwrapped package and accept its config gets hand-edited once —
no worse than not managing it declaratively at all.
