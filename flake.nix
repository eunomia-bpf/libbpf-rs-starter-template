{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, fenix, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages.default =
        let
          pkgs = nixpkgs.legacyPackages.${system};
          toolchain = with fenix.packages.${system}; combine [
            minimal.cargo
            minimal.rustc
          ];
        in
        (naersk.lib.${system}.override {
          cargo = toolchain;
          rustc = toolchain;
        }).buildPackage {
          hardeningDisable = [ "all" ];
          buildInputs = with pkgs; [
            clang
            zlib
          ];
          nativeBuildInputs = with pkgs; [
            elfutils
            pkg-config
          ];
          src = ./.;
        };
    });
}

