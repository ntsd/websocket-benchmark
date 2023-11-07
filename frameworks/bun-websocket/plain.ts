const server = Bun.serve({
  port: 9001,
  fetch(req, server) {
    if (server.upgrade(req)) {
      return;
    }
    return new Response("Upgrade failed :(", { status: 500 });
  },
  websocket: {
    async message(ws, message) {
      ws.send(message);
    },
  },
});

console.log(`Listening on ${server.hostname}:${server.port}`);
