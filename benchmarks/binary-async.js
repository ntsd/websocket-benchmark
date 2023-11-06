import ws from "k6/ws";
import { check } from "k6";
import { expect } from "https://jslib.k6.io/k6chaijs/4.3.4.3/index.js";

const iterations = 10000;

export const options = {};

export default function () {
  const url = "ws://localhost:9001/binary";
  const params = {};

  const res = ws.connect(url, params, function (socket) {
    socket.on("open", function open() {
      console.log(`VU ${__VU}: connected`);

      // send multiple messages
      for (let i = 0; i < iterations; i++) {
        socket.sendBinary(new Int32Array([i]).buffer);
      }
    });

    let received = 0;
    socket.on("binaryMessage", function (data) {
      received += 1;
      if (received >= iterations) {
        // assert received
        const int32Array = new Int32Array(data);
        expect(int32Array[0]).to.satisfy(function (num) {
          return num < iterations;
        });

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
