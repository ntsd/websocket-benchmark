# WebSocket Benchmark

This repository compares the speed of WebSocket frameworks for different languages.

## Frameworks

1. [Bun WebSockets](https://bun.sh/docs/api/websockets)
2. [uWebSockets.js](https://github.com/uNetworking/uWebSockets.js)
3. [gorilla/websocket](https://github.com/gorilla/websocket)
4. [fasthttp/websocket](https://github.com/fasthttp/websocket)
5. [tokio-tungstenite](https://github.com/snapview/tokio-tungstenite)

## Test Resources

To ensure a fair comparison, the resources will be limited using Docker to determine the most efficient framework per resource.

CPU Limit: 4 cores

Memory Limit: 1GB

Memory Swap: no swap

More details: <https://docs.docker.com/config/containers/resource_constraints/>

> Note: I performed some tests using my local machine without CPU limits.
> The results were that Go performed better than both Bun and Node.
> You could try it yourself on a high performance machine.

## Test Methods

Port Number: 9001

All tests are performed in concurrent connections using 64 and 128 virtual users (VUs) with a duration of 5 seconds for each test.

1. Connection Speed Test

path: `HTTP /`

The client connects to the server, gets a 101 status response, and then closes the connection.

2. Text Message Test

path: `WS /plain`

The client sends `{randomText}`, and the server responds with `{randomText}`.

3. JSON Message Test

path: `WS /json`

The client sends `{"number": {randomNumber}}` and the server responds as follows:

If the number is odd, the server sends `{"number": {randomNumber + 1}}`.

If the number is even, the server sends `{"number": {randomNumber + 2}}`.

4. Binary Message Test

path: `WS /binary`

The client sends a `number` in an Int32Array message.

If the number is odd, the server responds with `number+1`.

If the number is even, the server responds with `number+2`.

### Sync and Async Tests

Asynchronous test sends messages without waiting for the response message.

Synchronous test sends a message, waits for the response message, and then sends the next message.

### Why Test with a Condition Statement?

In real use cases, we don't only receive and send messages using frameworks. Other parts of the code, such as the JSON parser or DB connect, etc.

## Results

Check other results in the `./results` directory.

### Connection Method 64 VUS Result

| framework          | ws_sessions    | ws_connecting                                   |
| ------------------ | -------------- | ----------------------------------------------- |
| tokio-tungstenite  | 13137.162324/s | avg=4.77ms min=551.53µs med=4.44ms max=80.03ms  |
| bun-websocket      | 13069.55048/s  | avg=4.79ms min=525.68µs med=4.39ms max=100.63ms |
| uwebsocket-js      | 11882.529466/s | avg=5.27ms min=682.24µs med=4.81ms max=58.78ms  |
| fasthttp-websocket | 11524.364692/s | avg=5.44ms min=475.44µs med=4.94ms max=82.83ms  |
| gorilla-websocket  | 10754.352134/s | avg=5.83ms min=621.41µs med=5.28ms max=75.57ms  |

### JSON Sync Method 64 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 81725.569759/s   |
| bun-websocket      | 75606.357558/s   |
| uwebsocket-js      | 73137.835789/s   |
| fasthttp-websocket | 70818.793428/s   |
| gorilla-websocket  | 67720.472743/s   |

### JSON Async Method 64 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 442561.993299/s  |
| bun-websocket      | 611168.371646/s  |
| uwebsocket-js      | 563460.469109/s  |
| fasthttp-websocket | 508246.997076/s  |
| gorilla-websocket  | 498667.980764/s  |

### Binary Sync Method 64 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 80498.928468/s   |
| bun-websocket      | 69794.434565/s   |
| uwebsocket-js      | 75384.902691/s   |
| fasthttp-websocket | 68214.604466/s   |
| gorilla-websocket  | 67583.49342/s    |

### Binary Async Method 64 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 494548.05839/s   |
| bun-websocket      | 467317.123974/s  |
| uwebsocket-js      | 451046.522207/s  |
| fasthttp-websocket | 440250.603802/s  |
| gorilla-websocket  | 434406.944224/s  |

### Connection Method 128 VUS Result

| framework          | ws_sessions    | ws_connecting                                    |
| ------------------ | -------------- | ------------------------------------------------ |
| tokio-tungstenite  | 10270.04948/s  | avg=12.22ms min=927.69µs med=11.39ms max=143.9ms |
| bun-websocket      | 14545.719639/s | avg=8.65ms min=829.85µs med=7.89ms max=116.45ms  |
| uwebsocket-js      | 14264.117417/s | avg=8.78ms min=489.82µs med=7.89ms max=160.06ms  |
| fasthttp-websocket | 12807.055832/s | avg=9.78ms min=530.65µs med=8.86ms max=96.64ms   |

### JSON Sync Method 128 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 107341.626999/s  |
| bun-websocket      | 103615.608203/s  |
| uwebsocket-js      | 100386.438146/s  |
| fasthttp-websocket | 96270.837763/s   |

### JSON Async Method 128 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 434321.783546/s  |
| bun-websocket      | 620611.021552/s  |
| uwebsocket-js      | 560937.655412/s  |
| fasthttp-websocket | 531082.260734/s  |

## Contribution

### Starting the Server

You can use Docker Compose:

```sh
docker compose up fasthttp-websocket
```

Replace `fasthttp-websocket` with another framework.

You can check the list of servers in the `docker-compose.yaml` file.

for `bun-websocket`, the test methods are separate because Bun does not support multiple websocket paths, so you need to run each one individually.

### K6 benchmark

[Install K6](https://k6.io/docs/get-started/installation/) on your local and then run

```sh
make benchmark:all
```

replace `all` with a specific test method.

The test methods list (or can be found in `Makefile`):

- `all`
- `connection`
- `plain-async`
- `plain-sync`
- `json-async`
- `json-sync`
- `binary-async`
- `binary-sync`
