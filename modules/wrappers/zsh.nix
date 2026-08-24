let
  common =
    { pkgs, lib, ... }:
    let
      # Pinned directly from bazel's own source rather than depending on
      # pkgs.bazel: we use bazelisk instead (see modules/packages.nix and
      # modules/nix-ld.nix -- nixpkgs' plain `bazel` is a stale 7.x while
      # bazelisk fetches whatever a project's .bazelversion actually
      # pins), and pulling in the full bazel closure just for this one
      # completion file would bloat every host's shared zsh wrapper,
      # including headless ones that never run bazel at all.
      bazelZshCompletion = pkgs.runCommand "bazel-zsh-completion" { } ''
        mkdir -p $out/share/zsh/site-functions
        cp ${
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/bazelbuild/bazel/9.2.0/scripts/zsh_completion/_bazel";
            hash = "sha256-QJTchK3S8jgjvDQRhq32uEh/vV1BZL1S2YiRxBUR66Q=";
          }
        } $out/share/zsh/site-functions/_bazel
      '';
    in
    {
      zshAliases = {
        t = "tree";
        v = "nvim";
        # xclip defaults to the PRIMARY X11 selection (populated just by
        # highlighting text), not CLIPBOARD (populated by an explicit
        # copy action, e.g. Ctrl+C) -- this makes plain `xclip` match
        # what most apps' copy/paste actually mean. `\xclip` still gives
        # the raw default if ever needed.
        xclip = "xclip -selection clipboard";
      };

      env = {
        EDITOR = "nvim";
        BROWSER = lib.mkDefault "firefox";
        COLORTERM = "truecolor";
        # The upstream completion script's dynamic completions (command
        # list, flags, info keys) shell out to $BAZEL, defaulting to the
        # literal name "bazel" -- we only install bazelisk, so without
        # this override those invocations fail silently and produce no
        # completions, even though compdef correctly binds the widget.
        BAZEL = "bazelisk";
      };

      zshrc.content = ''
        # Generic completion directories, scanned in addition to whatever's
        # baked into the wrapper below -- covers the NixOS system profile
        # and the non-NixOS `nix profile install` homeProfile, so any
        # package that ships its own completions (not just bazel) gets
        # picked up automatically. Missing directories are silently
        # skipped by zsh.
        fpath=(
          ${bazelZshCompletion}/share/zsh/site-functions
          /run/current-system/sw/share/zsh/site-functions
          ~/.nix-profile/share/zsh/site-functions
          $fpath
        )

        autoload -Uz compinit
        compinit

        # The upstream script only declares "#compdef bazel", but the
        # binary we actually install is bazelisk (see modules/packages.nix)
        # -- bind its completion explicitly rather than relying on zsh's
        # inconsistent automatic alias-completion resolution.
        compdef _bazel bazelisk

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        eval "$(starship init zsh)"

        # NixOS hosts rebuild the system; everywhere else (e.g. the Ubuntu
        # home profile) just upgrades the user's own Nix profile.
        update() {
          if [ -f /etc/NIXOS ]; then
            sudo nixos-rebuild switch --flake="$HOME/repos/infra"
          else
            nix profile upgrade --all
          fi
        }
      '';
    };
in
{
  flake.wrappers.zsh =
    { wlib, ... }:
    {
      imports = [
        wlib.wrapperModules.zsh
        common
      ];
    };

  flake.wrappers.zsh-work =
    { wlib, ... }:
    {
      imports = [
        wlib.wrapperModules.zsh
        common
      ];
      env.BROWSER = "google-chrome";
    };
}
