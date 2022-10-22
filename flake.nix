{
  description = "Collection of more or less useful Nix flake templates";

  outputs = { self }: {

    templates = {
      org-website = {
        path = ./org-website;
        description = "Build a website using Org-mode";
      };

      python-fastapi = {
        path = ./python-fastapi;
        description = "Development-centered Python Fastapi API setup";
      };

      typescript-fastify = {
        path = ./typescript-fastify;
        description = "Development-centered Fastify API setup using Typescript";
      };
    };
  };
}
