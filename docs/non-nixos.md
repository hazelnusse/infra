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

## Fixing google-chrome's sandbox on Ubuntu 24.04+

`google-chrome` aborts on launch with `FATAL:
sandbox/linux/suid/client/setuid_sandbox_host.cc` — its setuid-root sandbox
helper can't work from an immutable, non-root-owned Nix store path, and its
fallback (Linux's unprivileged user namespaces) is blocked by an AppArmor
restriction Ubuntu enables by default from 24.04 onward. Ubuntu ships an
AppArmor exemption for Chrome, but only for the standard `.deb` install
path (`/opt/google/chrome/chrome`) — the Nix-installed binary lives
elsewhere, so that exemption doesn't apply.

`CHROME_DEVEL_SANDBOX` (sometimes suggested online) does **not** fix this
for the release `google-chrome` build — that variable is a Chromium
developer-build mechanism only; the shipped binary ignores it, and its own
wrapper script execs the real binary from a path inside the Nix store
regardless (`.../share/google/chrome/google-chrome`).

The actual fix: a custom AppArmor profile scoped to just this one binary
path, mirroring what Ubuntu's own Chrome exemption does — narrower and
safer than disabling the AppArmor restriction system-wide, and safer than
`--no-sandbox` (which disables the sandbox entirely rather than just
working around the namespace restriction). Uses a glob so it survives
Chrome version updates without needing to be reissued each time (the Nix
store hash and version both change on every update). Named
`nix-google-chrome`, not `chrome`, deliberately — Ubuntu's own exemption
at `/etc/apparmor.d/chrome` already uses the name `chrome` for its own
(differently-attached) profile, and how the kernel/`apparmor_parser`
handles two separately-loaded profiles sharing a name isn't confidently
verifiable, so this just avoids the question by not colliding at all
(the profile _name_ is only a label — it doesn't need to match the
attachment path's basename to work):

```
sudo tee /etc/apparmor.d/nix-google-chrome <<'EOF'
abi <abi/4.0>,
include <tunables/global>

profile nix-google-chrome /nix/store/*-google-chrome-*/share/google/chrome/google-chrome flags=(unconfined) {
  userns,

  include if exists <local/nix-google-chrome>
}
EOF
sudo apparmor_parser -r /etc/apparmor.d/nix-google-chrome
```

No need to reapply after a `google-chrome` update — the glob matches any
store hash/version — but if the _package name_ itself ever changes (e.g. a
future rename in nixpkgs), the profile would need updating to match.

## Fixing alacritty's "failed to find suitable GL configuration"

On a non-NixOS box, Nix's own bundled Mesa/GLVND doesn't correctly
negotiate with the host's actual GPU driver — especially on a hybrid
Intel+NVIDIA (Optimus-style) laptop, where the discrete NVIDIA driver
is proprietary and lives outside the Nix store entirely. NixOS wires
this up system-wide; a non-NixOS host needs
[nixGL](https://github.com/nix-community/nixGL) to bridge Nix-built
OpenGL apps to the host's real driver:

```
nix profile install --impure --profile ~/.nix-profile-nixgl github:nix-community/nixGL
```

(`--impure` is required — it inspects the live system's driver files
at build time, so this can't be folded into this repo's otherwise-pure
flake outputs. It also goes in its own separate profile rather than
`homeProfile`'s, so a plain `nix profile upgrade --all` — what `update`
runs — never has to deal with an impure package mixed into an
otherwise-reproducible profile.) This installs a `nixGL` binary that
auto-detects the right driver; `alacritty-nixgl`
(`modules/alacritty-nixgl.nix`, in `packageSets.work`) is a launcher
that runs the wrapped alacritty through it, and the `zsh-work` wrapper
(`modules/wrappers/zsh.nix`) redefines `alacritty` to reach that
launcher — no need to type `nixGL alacritty` by hand.

To upgrade nixGL itself later (separately from `update`, since it's in
its own profile), run `update-nixgl` — also defined in `zsh-work`.

## Making GNOME's Ctrl+Alt+T open alacritty

**Not resolved by this repo**: dconf is per-user mutable state on a
machine with no home-manager, so this is a one-time manual step.

Ctrl+Alt+T is handled by `gsd-media-keys`, which spawns whatever
`org.gnome.desktop.default-applications.terminal`'s `exec` key names
(the keybinding itself lives in
`org.gnome.settings-daemon.plugins.media-keys terminal` and needs no
change). On Ubuntu that key defaults to `x-terminal-emulator`, the
Debian alternatives symlink pointing at GNOME Terminal. Point it at the
launcher instead:

```
gsettings set org.gnome.desktop.default-applications.terminal exec \
  "$HOME/.nix-profile/bin/alacritty-nixgl"
```

Takes effect immediately — `gsd-media-keys` re-reads the key on every
keypress, so no logout or session restart is needed. Revert with
`gsettings reset org.gnome.desktop.default-applications.terminal exec`.

Note this has to be an **executable**, not the `alacritty` shell
function: `gsd-media-keys` spawns the process directly and never sources
a zshrc. Same for launching from the app grid — `alacritty-nixgl` ships
its own "Alacritty (nixGL)" desktop entry, separate from the wrapped
alacritty's plain "Alacritty" one (which runs without nixGL and so still
fails its GL init when started from the GNOME shell).

An absolute path through `~/.nix-profile/bin` rather than the bare name,
since a `$PATH` that happens to include the Nix profile isn't something
a session service's environment can be relied on to have. This means the
launcher must actually be installed before the key resolves: merge the
change, then run `update` (`nix profile upgrade --all` — the profile is
installed from `github:hazelnusse/infra`, not a local checkout).
