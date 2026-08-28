{
  flake.modules.nixos.x86-amd-pstate = {
    boot.kernelParams = [ "amd_pstate=active" ];
  };
}
