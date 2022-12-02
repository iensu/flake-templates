{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "hello-world";
        pkgs = import nixpkgs { inherit system; };
      in
        {
          packages.${name} = pkgs.stdenv.mkDerivation {
            inherit name;
            src = ./.;
            buildPhase = "mkdir -p $out; zig build install --prefix $out";
            nativeBuildInputs = [ pkgs.zig ];
            dontInstall = true;
            dontConfigure = true;

            XDG_CACHE_HOME = ".cache";
          };

          defaultPackage = self.packages.${system}.${name};

          apps.${name} = flake-utils.lib.mkApp { drv = self.defaultPackage; };

          devShell = pkgs.mkShell {
            nativeBuildInputs = [ pkgs.zig ];
          };
        });
}
