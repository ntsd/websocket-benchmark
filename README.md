# WebSocket Benchmark

This repository compares the speed of WebSocket frameworks for different languages.

## Frameworks

1. [Bun WebSockets](https://bun.sh/docs/api/websockets)
2. [uWebSockets.js](https://github.com/uNetworking/uWebSockets.js)
3. [gorilla/websocket](https://github.com/gorilla/websocket)
4. [fasthttp/websocket](https://github.com/fasthttp/websocket)
5. [tokio-tungstenite](https://github.com/snapview/tokio-tungstenite)
6. [websocketpp](https://github.com/zaphoyd/websocketpp)
7. [sip](https://github.com/PooyaEimandar/sib) Thanks to @PooyaEimandar

## Test Resources

To ensure a fair comparison, the resources will be limited using Docker to determine the most efficient framework per resource.

CPU Limit: 2 cores (Apply M3)

Memory Limit: 1GB

Memory Swap: no swap

More details: <https://docs.docker.com/config/containers/resource_constraints/>

> Note: I performed some tests using my local machine without CPU limits.
> The results were that Go performed better than both Bun and Node.
> You could try it yourself on a high performance machine.

## Test Methods

Port Number: 9001

All tests are performed in concurrent connections using 16, 64, 128 virtual users (VUs) with a duration of 5 seconds for each test.

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

### Connection Method 16 VUs Result

| Framework          | ws_sessions   | ws_connecting                                                             |
| ------------------ | ------------- | ------------------------------------------------------------------------- |
| bun-websocket      | 8499.867364/s | avg=1.84ms min=499.66µs med=1.65ms max=58.16ms p(90)=2.43ms p(95)=2.8ms   |
| fasthttp-websocket | 8412.220813/s | avg=1.86ms min=311.83µs med=1.69ms max=34.66ms p(90)=2.52ms p(95)=2.94ms  |
| tokio-tungstenite  | 8001.300394/s | avg=1.96ms min=476.37µs med=1.76ms max=55.22ms p(90)=2.59ms p(95)=3ms     |
| uwebsocket-js      | 7794.733031/s | avg=2ms min=482.7µs med=1.79ms max=103.02ms p(90)=2.63ms p(95)=3.06ms     |
| websocketpp        | 6494.632196/s | avg=2.42ms min=625µs med=2.22ms max=65.99ms p(90)=2.96ms p(95)=3.38ms     |
| gorilla-websocket  | 4041.91578/s  | avg=3.91ms min=362.91µs med=1.96ms max=202.4ms p(90)=9.77ms p(95)=12.61ms |
| sib                | 13.398208/s   | avg=747.03ms min=265.54µs med=1.62ms max=34.93s p(90)=4.51ms p(95)=5.66ms |

### JSON Sync Method 16 VUs Result

| Framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 37935.617767/s   |
| bun-websocket      | 36708.43469/s    |
| gorilla-websocket  | 34822.879647/s   |
| websocketpp        | 34657.213957/s   |
| fasthttp-websocket | 32446.244966/s   |
| uwebsocket-js      | 32044.007075/s   |
| sib                | 28158.671323/s   |

### JSON Async Method 16 VUs Result

| Framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 327224.988122/s  |
| bun-websocket      | 293216.98072/s   |
| websocketpp        | 291755.287335/s  |
| uwebsocket-js      | 266258.581015/s  |
| fasthttp-websocket | 209233.336363/s  |
| gorilla-websocket  | 201350.128115/s  |
| sib                | 37153.030704/s   |

### Binary Sync Method 16 VUs Result

| Framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 37347.855585/s   |
| websocketpp        | 36198.696847/s   |
| uwebsocket-js      | 34129.443009/s   |
| gorilla-websocket  | 34065.377308/s   |
| bun-websocket      | 34028.915716/s   |
| fasthttp-websocket | 30066.910145/s   |
| sib                | 28952.664725/s   |

### Binary Async Method 16 VUs Result

| Framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 297233.517612/s  |
| sib                | 292559.60582/s   |
| websocketpp        | 274422.674722/s  |
| gorilla-websocket  | 262322.002225/s  |
| bun-websocket      | 239248.186499/s  |
| fasthttp-websocket | 234948.363489/s  |
| uwebsocket-js      | 134965.345539/s  |

### Connection Method 64 VUS Result

| framework          | ws_sessions    | ws_connecting                                                             |
| ------------------ | -------------- | ------------------------------------------------------------------------- |
| tokio-tungstenite  | 13137.162324/s | avg=4.77ms min=551.53µs med=4.44ms max=80.03ms p(90)=6.78ms p(95)=7.72ms  |
| bun-websocket      | 13069.55048/s  | avg=4.79ms min=525.68µs med=4.39ms max=100.63ms p(90)=6.87ms p(95)=7.97ms |
| uwebsocket-js      | 11882.529466/s | avg=5.27ms min=682.24µs med=4.81ms max=58.78ms p(90)=7.58ms p(95)=8.8ms   |
| fasthttp-websocket | 11524.364692/s | avg=5.44ms min=475.44µs med=4.94ms max=82.83ms p(90)=8.3ms p(95)=9.7ms    |
| gorilla-websocket  | 10754.352134/s | avg=5.83ms min=621.41µs med=5.28ms max=75.57ms p(90)=8.87ms p(95)=10.48ms |

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
| bun-websocket      | 611168.371646/s  |
| uwebsocket-js      | 563460.469109/s  |
| fasthttp-websocket | 508246.997076/s  |
| gorilla-websocket  | 498667.980764/s  |
| tokio-tungstenite  | 442561.993299/s  |

### Binary Sync Method 64 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| tokio-tungstenite  | 80498.928468/s   |
| uwebsocket-js      | 75384.902691/s   |
| bun-websocket      | 69794.434565/s   |
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
# Run comprehensive benchmarks for all frameworks
make benchmark-comprehensive

# Or run individual test methods
make benchmark-all
```

The test methods list (or can be found in `Makefile`):

**Comprehensive Benchmarks:**

- `benchmark-comprehensive` - Test all frameworks with all methods and extract results
- `benchmark-all` - Run all tests across all frameworks systematically
- `extract-results` - Parse and display benchmark results

**Direct Script Usage:**

- `./websocket_benchmark.sh` - Run complete benchmark suite (same as `both`)
- `./websocket_benchmark.sh benchmark` - Only run benchmarks
- `./websocket_benchmark.sh extract` - Only parse existing results
- `./websocket_benchmark.sh help` - Show usage information

**Individual Tests:**

- `benchmark-individual` - Run individual test methods for the currently running framework
- `connection` - Test WebSocket connection establishment speed
- `plain-async` - Test plain text messaging (async)
- `plain-sync` - Test plain text messaging (sync)
- `json-async` - Test JSON messaging (async)
- `json-sync` - Test JSON messaging (sync)
- `binary-async` - Test binary messaging (async)
- `binary-sync` - Test binary messaging (sync)
