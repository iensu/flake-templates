{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustBinaries = if builtins.pathExists (builtins.toString ./rust-toolchain.toml)
                       then
                         pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
                       else
                         pkgs.rust-bin.stable.latest.default;
      in
        {
          devShell = with pkgs; mkShell {
            buildInputs = [
              rustBinaries
              rust-analyzer
              clippy
              rustfmt
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
        });
}
