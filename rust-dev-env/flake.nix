{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, rust-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        cargoConfig = builtins.fromTOML(builtins.readFile(./Cargo.toml));
        name = cargoConfig.package.name;
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustBinaries = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
        {
          devShell = with pkgs; mkShell {
            buildInputs = [ rustBinaries rust-analyzer ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
        });
}
