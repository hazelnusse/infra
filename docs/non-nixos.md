# Non-NixOS deployment

`packages.homeProfile` (`modules/home-profile.nix`) bundles every wrapped
program and CLI tool from `packageSets.base` + `packageSets.pc` into a
single installable — the same wrapped `git`/`tmux`/`starship`/`zsh`/`nixvim`
binaries as any NixOS host, with zero `$HOME` or username assumptions. This
applies to any machine where Nix runs as an add-on package manager rather
than as the OS itself — the motivating case is the corporate-managed
Ubuntu 24.04 laptop, with a different login username and no root-level
takeover of the machine, but nothing here is Ubuntu-specific.

## Prerequisite: installing Nix itself

**Not resolved by this repo.** Nix needs to be installed on the target
machine as an add-on package manager (no root-level NixOS, no taking over
the machine) before any of the below works. The exact install method
(daemon vs. single-user, whether it needs `sudo` at all) depends on real
constraints on that specific machine — locked-down `sudo` policy,
EDR/endpoint software that reacts to a new system daemon, disk
encryption/mount restrictions — that have to be checked against the
actual machine, not assumed here.

## Installing the profile

```
nix profile install github:hazelnusse/infra#homeProfile
```

Deliberately an _unlocked_ flake reference (no pinned revision) — `nix
profile upgrade` only works against packages installed this way.

## Upgrading

```
nix profile upgrade --all
```

or just run `update` once the wrapped `zsh` (below) is your shell — its
`update` function runs this automatically when it detects it's not on
NixOS (checks for `/etc/NIXOS`).

## Using the wrapped zsh as your login shell

**May not work on a locked-down machine.** `chsh -s <path>` typically
requires the target shell to be listed in `/etc/shells`, and adding to
that file needs root — something you may not have on a corporate laptop.
Try:

```
chsh -s "$(readlink -f ~/.nix-profile/bin/zsh)"
```

If that's rejected, a fallback that needs no admin rights: add `exec
~/.nix-profile/bin/zsh` as the last line of whatever your actual login
shell already reads (e.g. `~/.bashrc`), so it hands off to the wrapped
zsh once it starts.

## Fixing missing prompt icons (Nerd Font glyphs)

Starship's default prompt uses Nerd Font icons (e.g. the git branch
symbol) — `nerd-fonts.jetbrains-mono` is in `packageSets.pc` so the font
files land in the profile, but two more steps are needed that Nix can't
do for you on a non-NixOS box:

1. Register the font with fontconfig — it's on disk but not yet known to
   the system font cache:

   ```
   mkdir -p ~/.local/share/fonts
   ln -s ~/.nix-profile/share/fonts/*/*.ttf ~/.local/share/fonts/
   fc-cache -f
   ```

   Confirm it registered correctly (look for `JetBrainsMono Nerd Font
Mono` specifically — that's the monospace-flagged variant GUI font
   pickers filter for; the base `Nerd Font` and `Nerd Font Propo`
   variants are proportional and won't show up in a monospace-only
   picker):

   ```
   fc-list : family | grep -i jetbrains
   ```

2. Point your terminal at it. GUI font pickers can lag behind a fresh
   `fc-cache` — they sometimes cache the font list at process (or even
   session) startup. If a newly-registered font doesn't show up in your
   terminal's font preferences, try killing and restarting the terminal
   process first (e.g. `killall gnome-terminal-server`), and a full
   logout/login or reboot if that's not enough.

   If the picker still won't list it, set it directly instead (GNOME
   Terminal example):

   ```
   PROFILE_UUID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
   gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_UUID/ use-system-font false
   gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_UUID/ font 'JetBrainsMono Nerd Font Mono 12'
   ```
