# Testing

`nix flake check` runs everything: evaluation of every NixOS host, formatting
(treefmt), the dendritic-pattern flake-file sanity check, and the
`runNixOSTest` VM checks under `modules/tests/`.

## Running locally

```
nix flake check
```

or target a single check directly, e.g. to iterate on one VM test without
rebuilding everything else:

```
nix build .#checks.x86_64-linux.<name> -L
```

`-L` streams the VM's console output live, which is the fastest way to
debug a failing test.

## What the VM checks cover

- `vm-smoke-test` — boots a bare NixOS VM to `multi-user.target`. Exists to
  prove the test infrastructure itself (and KVM acceleration) works, not to
  test any of this repo's modules.
- `base-x86-efi-pc-boot` — boots a VM importing the `base` + `x86-efi` + `pc` module
  groups (the same combination `p14s-personal` imports today), and asserts
  the system reaches `multi-user.target`, `sshd.service` comes up, and
  `systemctl is-system-running --wait` succeeds (no failed units, GNOME
  included). New group combinations get their own check here as new hosts
  are added.

## KVM acceleration

These tests run dramatically faster with hardware-accelerated KVM than
without it (seconds vs. minutes, via QEMU's TCG software fallback). On a
Linux dev machine, confirm `/dev/kvm` exists and is accessible
(`ls -l /dev/kvm`, and that your user is in the `kvm` group). CI gets this
automatically via `cachix/install-nix-action`'s `enable_kvm: true` default
(handles the udev rule) combined with `system-features = kvm` in
`extra_nix_config` (tells Nix's build sandbox it's allowed to pass
`/dev/kvm` through to the build).

## Caching

CI caches the Nix store via `nix-community/cache-nix-action`, keyed on a
hash of the whole tree (except `.git`). The cache is capped below
GitHub's 10GB repo-wide limit and garbage-collected before each save; a
new cache is only saved when that hash actually changes, so a re-run or
a docs-only commit reuses the existing cache exactly rather than saving
a redundant duplicate. GitHub Actions caches are immutable once saved
under a given key — restores fall back to the most recently created
cache with a matching `nix-<os>-` prefix when there's no exact hit.
