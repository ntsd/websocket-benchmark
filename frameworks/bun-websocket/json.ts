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
      let jsonMsg = JSON.parse(message as string);

      if (jsonMsg.number % 2) {
        jsonMsg.number += 1;
      } else {
        jsonMsg.number += 2;
      }

      ws.send(JSON.stringify(jsonMsg));
    },
  },
});

console.log(`Listening on ${server.hostname}:${server.port}`);
