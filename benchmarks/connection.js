import ws from "k6/ws";
import { check } from "k6";

export const options = {};

export default function () {
  const url = "ws://localhost:9001/connection";
  const params = {};

  const res = ws.connect(url, params, function (socket) {
    socket.on("open", function () {
      socket.close();
    });
  });

  check(res, { "status is 101": (r) => r && r.status === 101 });
}
