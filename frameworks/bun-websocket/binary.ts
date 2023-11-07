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
      const int32Array = new Int32Array(message as Buffer);

      if (int32Array[0] % 2) {
        int32Array[0] += 1;
      } else {
        int32Array[0] += 2;
      }

      ws.send(int32Array.buffer);
    },
  },
});

console.log(`Listening on ${server.hostname}:${server.port}`);
