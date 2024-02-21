let foo = 52;

const server = Bun.serve({
  port: 3000,
  fetch: async (req: Request) => {
    if (req.method == "GET") {
      return new Response("Hello World");
    } else if (req.method == "POST") {
      const body = req.body;
      const json = await Bun.readableStreamToJSON(body);
      return new Response(JSON.stringify(json));
    }
    return new Response("Not implemented");
  },
});

console.log(`Listening on localhost:${server.port}`);
