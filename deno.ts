async function handler(req: Request): Response {
  if (req.method == "GET") {
    return new Response("Hello World");
  } else if (req.method == "POST") {
    const json = await req.json();
    return new Response(JSON.stringify(json));
  }
  return new Response("Not implemented");
}

Deno.serve({ port: 3000, hostname: "127.0.0.1", handler });
