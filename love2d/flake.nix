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
          devShell = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.lua
              pkgs.lua-language-server
              pkgs.luaformatter
              pkgs.love
            ];
          };
        });
}
