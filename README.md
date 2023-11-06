# WebSocket Benchmark

compare WebSocket Frameworks for different languages

## Framework

1. [Bun WebSockets](https://bun.sh/docs/api/websockets)
2. [uWebSockets.js](https://github.com/uNetworking/uWebSockets.js)
3. [gorilla/websocket](https://github.com/gorilla/websocket)
4. [fasthttp/websocket](https://github.com/fasthttp/websocket)
5. [tokio-tungstenite](https://github.com/snapview/tokio-tungstenite)

## Test resource

To be fair the resource will limit using docker to see the most efficient framework per resource.

CPU Limit: 4 cores (0-3)
Memory Limit: 1GB
Memory Swap: no swap

More details: <https://docs.docker.com/config/containers/resource_constraints/>

## Test methods

Port Number: 9001

Test all in concurrent connections 1, 4, 16 virtual users (VUs) duration 5 seconds.

1. Connection Speed

path: `HTTP /`

Client connect to Server return status `101` then client close the connection.

1. Sending and receiving plain text message

path: `WS /plain`

Client sending `{randomText}`, the server response `{randomText}`.

1. Sending and receiving JSON message

path: `WS /json`

Client sending `{"message":"{randomText}"}`, the server response `{"message":"{randomText}"}`.

1. Sending and receiving binary message

path: `WS /binary`

Client sending `Int32Array` binary message, the server `Int32Array` binary message.

## Test Metrics

1. Iterations per second
2. Average letency
3. Errors
