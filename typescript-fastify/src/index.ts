import { buildServer } from "./server";

const PORT: string = process.env.PORT || "8080";
const HOST: string = process.env.HOST || "127.0.0.1";

// Make it easier for Docker to shut down the server
process.on("SIGINT", () => process.exit(0));
process.on("SIGTERM", () => process.exit(0));

const start = async () => {
  const server = buildServer({
    logger: true,
  });

  try {
    server.listen({ port: parseInt(PORT, 10), host: HOST });
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
