const http = require("node:http");

const hostname = "127.0.0.1";
const port = 3000;

const server = http.createServer((req, res) => {
  if (req.method == "GET") {
    res.statusCode = 200;
    res.end("Hello World");
    return;
  } else if (req.method == "POST") {
    let body = [];
    req
      .on("data", (chunk) => {
        body.push(chunk);
      })
      .on("end", () => {
        body = Buffer.concat(body).toString();
        res.statusCode = 200;
        res.end(JSON.stringify(JSON.parse(body)));
      });
    return;
  }

  res.statusCode = 500;
  res.end("Not implemented");
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
