import ws from "k6/ws";
import { check } from "k6";
import { expect } from "https://jslib.k6.io/k6chaijs/4.3.4.3/index.js";

const iterations = 10000;

export const options = {};

export default function () {
  const url = "ws://localhost:9001/json";
  const params = {};

  const res = ws.connect(url, params, function (socket) {
    socket.on("open", function open() {
      console.log(`VU ${__VU}: connected`);

      // send multiple messages
      for (let i = 0; i < iterations; i++) {
        socket.send(JSON.stringify({ message: `number: ${i}` }));
      }
    });

    let received = 0;
    socket.on("message", function (data) {
      received += 1;
      if (received >= iterations) {
        // assert received
        data = JSON.parse(data);
        expect(data.message).to.match(/number\:\s[0-9]+/);

        socket.close();
      }
    });

    socket.on("close", function () {
      console.log(`VU ${__VU}: disconnected`);
    });

    socket.on("error", function (e) {
      if (e.error() != "websocket: close sent") {
        console.error("An unexpected error occurred: ", e.error());
      }
    });
  });

  check(res, { "status is 101": (r) => r && r.status === 101 });
}
