{ config, lib, ... }:
{
  systems = config.configurations.nixos |> lib.mapAttrsToList (name: nixos: nixos.system);
}
