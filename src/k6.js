import ws from "k6/ws";
import { check } from "k6";

export const options = {
  vus: 10,
  iterations: 10,
};

export default function () {
  const url = "ws://your-websocket-url";
  const params = { tags: { my_tag: "hello" } };

  const res = ws.connect(url, params, function (socket) {
    socket.on("open", function open() {
      console.log(`VU ${__VU}: connected`);
      socket.send(Date.now());

      // Send a message every second for 10 seconds
      var counter = 0;
      const t = setInterval(function timeout() {
        socket.send(Date.now());
        if (++counter === 10) {
          clearInterval(t);
          socket.close();
        }
      }, 1000);
    });

    socket.on("message", function (data) {
      console.log(`Received message: ${data}`);
    });

    socket.on("close", function () {
      console.log(`VU ${__VU}: disconnected`);
    });

    socket.on("error", function (e) {
      if (e.error() != "websocket: close sent") {
        console.log("An unexpected error occurred: ", e.error());
      }
    });
  });

  check(res, { "status is 101": (r) => r && r.status === 101 });
}
