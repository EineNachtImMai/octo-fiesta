{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = {self, ...} @ inputs: let
    module = import ./nix/nixos-modules.nix self;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        # "x86_64-darwin"
        # "aarch64-linux"
        # "aarch64-darwin"
      ];
      flake = {
        nixosModules = rec {
          octo-fiesta = module;
          default = octo-fiesta;
        };
      };
      perSystem = {pkgs, ...}: {
        packages = rec {
          octo-fiesta = pkgs.callPackage ./nix {};
          default = octo-fiesta;
        };
      };
    };
}
