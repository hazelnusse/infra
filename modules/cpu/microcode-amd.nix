{
  flake.modules.nixos.x86-microcode-amd = {
    hardware.cpu.amd.updateMicrocode = true;
  };
}
