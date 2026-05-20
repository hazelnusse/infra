{
  flake.modules.nixos.base = {
    hardware.cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };
}
