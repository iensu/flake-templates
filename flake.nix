{
  description = "Collection of more or less useful Nix flake templates";

  outputs = { self }: {

    templates = {
      org-website = {
        path = ./org-website;
        description = "Build a website using Org-mode";
      };

      guile-http = {
        path = ./guile-http;
        description = "Guile project prepared for HTTP stuff";
      };

      node-dev = {
        path = ./node-dev;
        description = "Simple node.js dev environment";
      };

      python-fastapi = {
        path = ./python-fastapi;
        description = "Development-centered Python Fastapi API setup";
      };

      rust-bin = {
        path = ./rust-bin;
        description = "Naersk-based Rust flake to build binary applications";
      };

      rust-wasm-lib = {
        path = ./rust-wasm-lib;
        description = "Rust lib crate with wasm32-unknown-unknown target configured";
      };

      typescript-fastify = {
        path = ./typescript-fastify;
        description = "Development-centered Fastify API setup using Typescript";
      };

      zig-bin = {
        path = ./zig-bin;
        description = "Zig binary application.";
      };
    };
  };
}
