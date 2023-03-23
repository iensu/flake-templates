{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, rust-overlay, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        cargoConfig = builtins.fromTOML(builtins.readFile(./Cargo.toml));
        name = cargoConfig.package.name;
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustBinaries = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        naersk-lib = pkgs.callPackage naersk {
          cargo = rustBinaries;
          rustc = rustBinaries;
        };
        package = naersk-lib.buildPackage {
          src = ./.;
          nativeBuildInputs = with pkgs; [ ];
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
            buildInputs = [
              rustBinaries # Rust-related binaries (rustc, cargo, clippy, ...)
              binaryen     # Tools for optimizing wasm modules (wasm-* family of executables)
              wabt         # Tools for working with wasm text format (wasm2wat, wat2wasm, ...)
              wasmtime     # For running the wasm module through WASI (wasmtime --invoke <fn> file.wasm [...args])
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
            RUST_LOG = "debug";
          };
        });
}
