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

Test all in concurrent connections 1, 4, 16, 64 virtual users (VUs) duration 1 minute or 10000 iterations.

1. Connection Speed

Client connect to Server return status `101`

2. Sending and receiving text message

Client sending `{randomText}`, the server response `{randomText}`

3. Sending and receiving JSON message

Client sending `{"message":"{randomText}"}`, the server response `{"message":"{randomText}"}`

4. Sending and receiving Protobuf message

Client sending Protobuf message, the server response Protobuf message

## Test Metrics

1. Iterations per second
2. Average letency
3. Errors
