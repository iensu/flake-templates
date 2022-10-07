import tap from "tap";
import { buildServer } from "./server";

tap.test("API server is alive", async (_t) => {
  const server = buildServer();
  const response = await server.inject().get("/").end();

  tap.equal(response.statusCode, 200);
  tap.equal(response.body, "alive");
});
