{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        name = "main_app"; # Change this!
        version = "0.1.0";
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustBinaries = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        naersk-lib = pkgs.callPackage naersk {
          cargo = rustBinaries;
          rustc = rustBinaries;
        };
        nativeBuildInputs = [];
        package = naersk-lib.buildPackage {
          inherit name version nativeBuildInputs;

          root = builtins.path { path = ./.; inherit name; };
          cargoBuildOptions = x: x ++ [ "--package" name ];
          cargoTestOptions = x: x ++ [ "--package" name ];
          release = true;
        };
      in
        {
          packages.${name} = package;
          defaultPackage = self.packages.${system}.${name};

          apps.${name} = {
            type = "app";
            program = "${package}/bin/${name}";
          };

          devShell = with pkgs; mkShell {
            inherit nativeBuildInputs;

            buildInputs = [
              rustBinaries

              cargo-outdated
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
        });
}
