{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        cargoConfig = builtins.fromTOML(builtins.readFile(./Cargo.toml));
        name = cargoConfig.package.name;
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
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
            buildInputs = [ cargo rustc rustfmt rust-analyzer rustPackages.clippy ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
            RUST_LOG = "debug";
          };
        });
}
