import fastify, { FastifyInstance, FastifyServerOptions } from "fastify";

type ServerConfig = FastifyServerOptions & {};

export const buildServer = (opts: ServerConfig = {}): FastifyInstance => {
  const server = fastify(opts);

  server.get("/", (_request, reply) => {
    reply.send("alive");
  });

  return server;
};
