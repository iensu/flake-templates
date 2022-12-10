{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = (import nixpkgs {
        inherit system;
        config = {
          packageOverrides = p: {
            gnutls = p.gnutls.override {
              guile = p.guile_3_0;
              guileBindings = true;
            };

          };
        };
      });
    in
      {
        devShell = pkgs.mkShell {
          GUILE_LOAD_PATH = "./src";
          GUILE_TLS_CERTIFICATE_DIRECTORY = "${pkgs.cacert}/etc/ssl/certs";

          buildInputs = with pkgs; [ guile_3_0 gnutls cacert ];
        };
      });
}
