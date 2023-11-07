const uWS = require("uWebSockets.js");

const port = 9001;

const drainFn = (ws) => {
  console.error("webSocket backpressure: " + ws.getBufferedAmount());
};

const app = uWS
  .App()
  .ws("/binary", {
    open: (ws) => {},
    message: (ws, message, isBinary) => {
      const int32Array = new Int32Array(message);

      if (int32Array[0] % 2) {
        int32Array[0] += 1;
      } else {
        int32Array[0] += 2;
      }

      ws.send(int32Array.buffer, true);
    },
    drain: drainFn,
    close: (ws, code, message) => {},
  })
  .ws("/json", {
    open: (ws) => {},
    message: (ws, message, isBinary) => {
      let receivedMsg = Buffer.from(message).toString();
      let jsonMsg = JSON.parse(receivedMsg);

      if (jsonMsg.number % 2) {
        jsonMsg.number += 1;
      } else {
        jsonMsg.number += 2;
      }

      ws.send(JSON.stringify(jsonMsg));
    },
    drain: drainFn,
    close: (ws, code, message) => {},
  })
  .ws("/plain", {
    open: (ws) => {},
    message: (ws, message, isBinary) => {
      ws.send(Buffer.from(message).toString());
    },
    drain: drainFn,
    close: (ws, code, message) => {},
  })
  .ws("/connection", {
    open: (ws) => {},
    message: (ws, message, isBinary) => {},
    drain: drainFn,
    close: (ws, code, message) => {},
  })
  .listen(port, (token) => {
    if (token) {
      console.log("Listening to port " + port);
    } else {
      console.error("Failed to listen to port " + port);
    }
  });
