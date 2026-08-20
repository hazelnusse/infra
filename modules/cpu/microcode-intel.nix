{
  flake.modules.nixos.x86-microcode-intel = {
    hardware.cpu.intel.updateMicrocode = true;
  };
}
