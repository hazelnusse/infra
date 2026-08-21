# Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix), wired
into every NixOS host via `flake.modules.nixos.base` (`modules/sops.nix`).

**This is not yet actionable.** No host declares a secret, and neither
`.sops.yaml` nor any secrets file (e.g. `secrets.yaml`) exists in this repo
yet — none of the commands below have anything to run against. This
documents the workflow for when that changes, starting with the Pi-hole
admin password in Phase 5. The `sops` and `ssh-to-age` CLI tools are
already installed on every host (`modules/packages.nix`) so they're ready
once needed.

## How it works

Each host decrypts its own secrets at boot/activation using an
[age](https://github.com/FiftyThreeDegrees/age) key derived from its own SSH
host key (`sops.age.sshKeyPaths` defaults to
`/etc/ssh/ssh_host_ed25519_key`, and every host already has
`services.openssh.enable = true` via `base`) — no separate key file needs
deploying to a host. Decrypted secrets land in `/run/secrets` (tmpfs, wiped
on reboot), never in the Nix store.

## Editing secrets

Once a host declares its first secret, this repo will have a `.sops.yaml`
(mapping which age/PGP keys can decrypt which secrets files) and at least
one encrypted secrets file (e.g. `secrets.yaml`). To edit:

```
sops edit secrets.yaml
```

This decrypts to a temporary file, opens `$EDITOR`, and re-encrypts on save.
It needs a private key it can decrypt with — see "Your own key" below.

## Adding a new host as a recipient

A host's age public key is derived from its SSH host key
(`ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`, run once the host is
installed). Add it to `.sops.yaml`, then re-encrypt existing secrets for the
new recipient:

```
sops updatekeys secrets.yaml
```

## Your own key

Editing secrets from your own laptop needs a personal age private key
capable of decrypting them (add its public key to `.sops.yaml` alongside
each host's). Keep it somewhere durable, not just a bare file on one
machine — a private note in Bitwarden (which the household already uses)
is a reasonable place, since it's already backed up and shared across your
own devices.

## Looking up a plaintext value

Bitwarden isn't integrated with sops-nix in any automated way — it's just
where you look up a secret's plaintext value before typing it into
`sops edit`. For example, to set the Pi-hole admin password once that
secret exists:

```
bw get password "Pi-hole admin"
```

then paste the result into the editor `sops edit` opens.
