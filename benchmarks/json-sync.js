import ws from "k6/ws";
import { check } from "k6";

export const options = {};

export default function () {
  const url = "ws://localhost:9001/json";
  const params = {};

  const res = ws.connect(url, params, function (socket) {
    let i = 0;

    socket.on("open", function open() {
      // console.log(`VU ${__VU}: connected`);

      // send initial message
      socket.send(JSON.stringify({ number: i }));
    });

    socket.on("message", function (data) {
      i += 1;

      // send the next message after receive message
      socket.send(JSON.stringify({ number: i }));
    });

    socket.on("close", function () {
      // console.log(`VU ${__VU}: disconnected`);
    });

    socket.on("error", function (e) {
      if (e.error() != "websocket: close sent") {
        console.error("An unexpected error occurred: ", e.error());
      }
    });
  });

  check(res, { "status is 101": (r) => r && r.status === 101 });
}
