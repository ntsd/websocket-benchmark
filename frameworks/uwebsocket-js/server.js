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
      ws.send(int32Array.buffer, true);
    },
    drain: drainFn,
    close: (ws, code, message) => {},
  })
  .ws("/json", {
    open: (ws) => {},
    message: (ws, message, isBinary) => {
      let receivedMsg = Buffer.from(message).toString();
      try {
        let jsonMsg = JSON.parse(receivedMsg);
        ws.send(JSON.stringify(jsonMsg));
      } catch (error) {
        ws.send(error);
      }
    },
    drain: drainFn,
    close: (ws, code, message) => {},
  })
  .ws("/plain", {
    open: (ws) => {},
    message: (ws, message, isBinary) => {
      let receivedMsg = Buffer.from(message).toString();
      ws.send(receivedMsg);
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
