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
        rustVersion = "1.64.0";
        wasmTarget = "wasm32-unknown-unknown";
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustWithWasmTarget = pkgs.rust-bin.stable.${rustVersion}.default.override {
          targets = [wasmTarget];
        };
        naersk-lib = pkgs.callPackage naersk {
          cargo = rustWithWasmTarget;
          rustc = rustWithWasmTarget;
        };
        package = naersk-lib.buildPackage ./.;
      in
        {
          packages.${name} = package;
          defaultPackage = self.packages.${system}.${name};

          apps.${name} = {
            type = "app";
            program = "${package}/bin/${name}";
          };

          devShell = with pkgs; mkShell {
            buildInputs = [ rustWithWasmTarget rustfmt rust-analyzer rustPackages.clippy wabt ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
            RUST_LOG = "debug";
          };
        });
}
