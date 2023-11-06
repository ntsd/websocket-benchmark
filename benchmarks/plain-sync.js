import ws from "k6/ws";
import { check } from "k6";
import { expect } from "https://jslib.k6.io/k6chaijs/4.3.4.3/index.js";

const iterations = 10000;

export const options = {};

export default function () {
  const url = "ws://localhost:9001/plain";
  const params = {};

  const res = ws.connect(url, params, function (socket) {
    let i = 0;

    socket.on("open", function open() {
      console.log(`VU ${__VU}: connected`);

      // send initial message
      socket.send(`number: ${i}`);
    });

    socket.on("message", function (data) {
      i += 1;
      if (i >= iterations) {
        // assert received
        expect(data).to.equal(`number: ${i - 1}`);

        socket.close();
        return;
      }

      // send the next message after receive message
      socket.send(`number: ${i}`);
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
