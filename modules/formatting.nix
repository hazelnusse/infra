{ inputs, ... }:
{
  flake-file.inputs.treefmt = {
    url = "github:numtide/treefmt-nix";
    flake = false;
  };
  imports = [ (inputs.treefmt + "/flake-module.nix") ];

  perSystem = {
    treefmt = {
      #projectRootFile = "flake.nix";
      programs = {
        #prettier.enable = true;
        #shfmt.enable = true;
      };
      settings = {
        on-unmatched = "fatal";
        #global.excludes = [
        #  "*.jpg"
        #  "*.png"
        #  "LICENSE"
        #];
      };
    };
    #pre-commit.settings.hooks.treefmt.enable = true;
  };
}
