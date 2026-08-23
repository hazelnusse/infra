# Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix), wired
into every NixOS host via `flake.modules.nixos.base` (`modules/sops.nix`).

Each host gets its own secrets file, `secrets/<hostname>.yaml`, encrypted
only for the recipients that need it — that host's own key plus your
personal key. `pi4`'s first secret (`root-password-hash`, in
`secrets/pi4.yaml`) is the working example this doc now assumes; a new
host's secrets get their own new file rather than being added to an
existing one, so a compromised host's key only ever exposes that host's own
secrets, not every host's.

## How it works

Each host decrypts its own secrets at boot/activation using an
[age](https://github.com/FiftyThreeDegrees/age) key derived from its own SSH
host key (`sops.age.sshKeyPaths` defaults to
`/etc/ssh/ssh_host_ed25519_key`, and every host already has
`services.openssh.enable = true` via `base`) — no separate key file needs
deploying to a host. Decrypted secrets land in `/run/secrets` (tmpfs, wiped
on reboot), never in the Nix store.

## Editing secrets

```
sops secrets/pi4.yaml
```

This decrypts to a temporary file, opens `$EDITOR`, and re-encrypts on save
(uses `secrets/pi4.yaml`'s recipients from `.sops.yaml` automatically,
including for a brand-new file that doesn't exist yet). Needs a private key
it can decrypt with — see "Your own key" below.

## Adding a new secret to an existing host

Add a `configurations.nixos.<host>.module`-scoped `sops.secrets.<name> = { };`
declaration (see `modules/hosts/pi4-secrets.nix` for the pattern), then
reference `config.sops.secrets.<name>.path` wherever the decrypted value is
needed (e.g. `users.users.root.hashedPasswordFile`). The `sops.defaultSopsFile`
set per-host already points at that host's `secrets/<hostname>.yaml`, so a
bare `sops.secrets.<name> = { };` is enough — no need to repeat the file path
per secret.

## Adding a new host

A host's age public key is derived from its SSH host key, run once the host
is installed and reachable:

```
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Add a new `&<hostname>` key entry and a new `creation_rules` block to
`.sops.yaml` (copy `pi4`'s as a template), then create that host's own
secrets file the same way as above (`sops secrets/<hostname>.yaml`) — a
fresh file, not an addition to another host's.

## Your own key

Editing secrets from your own laptop needs a personal age private key
capable of decrypting them (its public key is already in `.sops.yaml`,
alongside each host's). Keep it somewhere durable, not just a bare file on
one machine — a private note in Bitwarden (which the household already
uses) is a reasonable place, since it's already backed up and shared across
your own devices. (Done: `~/.config/sops/age/keys.txt`'s contents are saved
there.)

## Looking up a plaintext value

Bitwarden isn't integrated with sops-nix in any automated way — it's just
where you look up a secret's plaintext value before typing it into
`sops edit`/`sops <file>`. For a password specifically, hash it first
(`nix shell nixpkgs#mkpasswd --command mkpasswd -m sha-512`, entered
interactively so the plaintext never lands in shell history) and paste the
resulting hash, not the plaintext, if the consumer expects a
`hashedPasswordFile`-style value — that's how `pi4`'s root password is
handled.
