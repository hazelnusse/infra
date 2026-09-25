{ config, ... }:
{
  # Lets deploy-nuc copy an unsigned closure as this user; root SSH to
  # these hosts is disabled, and `--use-remote-sudo` only elevates the
  # activation step, not nix-copy-closure.
  flake.modules.nixos.pc.nix.settings.trusted-users = [ config.username ];
}
