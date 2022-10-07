{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python39;
        requiredPackages = let
          splitString = pkgs.lib.strings.splitString;
          head = pkgs.lib.lists.head;
          fileContents = pkgs.lib.strings.fileContents;
          lines = splitString "\n" (fileContents ./requirements.txt);
          depStrings = map (line: head (splitString "==" line)) lines;
        in
          map (dep: pkgs.lib.getAttr dep pkgs.python39Packages) depStrings;
        dependencies = [ python ] ++ requiredPackages;
        devDependencies = with pkgs.python39Packages; [
          flake8
          python-lsp-server
        ];
      in
        {
          devShell = pkgs.mkShell {
            nativeBuildInputs = dependencies ++ devDependencies;
          };
        });
}
