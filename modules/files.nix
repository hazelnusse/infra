{ inputs, ... }:
{
  flake-file.inputs.files = {
    url = "github:mightyiam/files";
    flake = false;
  };
  imports = [ (inputs.files + "/module.nix") ];

  perSystem = psArgs: {
    packages.write-files = psArgs.config.files.writer.drv;
  };
}
