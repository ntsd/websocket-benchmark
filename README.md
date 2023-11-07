# WebSocket Benchmark

comparing speed of WebSocket Frameworks for different languages

## Framework

1. [Bun WebSockets](https://bun.sh/docs/api/websockets)
2. [uWebSockets.js](https://github.com/uNetworking/uWebSockets.js)
3. [gorilla/websocket](https://github.com/gorilla/websocket)
4. [fasthttp/websocket](https://github.com/fasthttp/websocket)
5. [tokio-tungstenite](https://github.com/snapview/tokio-tungstenite)

## Test resource

To be fair the resource will limit using docker to see the most efficient framework per resource.

CPU Limit: 4 cores
Memory Limit: 1GB
Memory Swap: no swap

More details: <https://docs.docker.com/config/containers/resource_constraints/>

> I did some test on No CPU Limit in Local Machine.
> seem Go result is better than Bun and Node.

## Test methods

Port Number: 9001

Test all in concurrent connections 64, 128 virtual users (VUs) duration 5 seconds for each test.

1. Connection Speed

path: `HTTP /`

Client connect to Server return status `101` then client close the connection.

2. Sending and receiving plain text message

path: `WS /plain`

Client sending `{randomText}`, the server response `{randomText}`.

3. Sending and receiving JSON message

path: `WS /json`

Client sending `{"number": {randomNumber}}`

if number is odd the server response `{"number": {randomNumber + 1}}`

if number is even the server response `{"number": {randomNumber + 2}}`

4. Sending and receiving binary message

path: `WS /binary`

Client sending `number` in Int32Array message

if number is odd the server response `number+1`

if number is even the server response `number+2`

### Sync and Async Test

Asynchronous Test mean test mean send message without waiting the response message.

Synchronous Test mean send message then send it again after receive the response message.

### Why test with statement?

because in the real use case, we didn't only use the receive and sending of the frameworks but we have other part of code example JSON parser, DB connect, etc.

## Results

check other results in `./results` directory

### Connection Method 64 VUS Result

| framework          | ws_sessions    | ws_connecting                                   |
| ------------------ | -------------- | ----------------------------------------------- |
| bun-websocket      | 13069.55048/s  | avg=4.79ms min=525.68µs med=4.39ms max=100.63ms |
| uwebsocket-js      | 11882.529466/s | avg=5.27ms min=682.24µs med=4.81ms max=58.78ms  |
| fasthttp-websocket | 11524.364692/s | avg=5.44ms min=475.44µs med=4.94ms max=82.83ms  |
| gorilla-websocket  | 10754.352134/s | avg=5.83ms min=621.41µs med=5.28ms max=75.57ms  |

### JSON Sync Method 64 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
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

### Connection Method 128 VUS Result

| framework          | ws_sessions    | ws_connecting                                   |
| ------------------ | -------------- | ----------------------------------------------- |
| bun-websocket      | 14545.719639/s | avg=8.65ms min=829.85µs med=7.89ms max=116.45ms |
| uwebsocket-js      | 14264.117417/s | avg=8.78ms min=489.82µs med=7.89ms max=160.06ms |
| fasthttp-websocket | 12807.055832/s | avg=9.78ms min=530.65µs med=8.86ms max=96.64ms  |

### JSON Sync Method 128 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| bun-websocket      | 103615.608203/s  |
| uwebsocket-js      | 100386.438146/s  |
| fasthttp-websocket | 96270.837763/s   |

### JSON Async Method 128 VUS Result

| framework          | ws_msgs_received |
| ------------------ | ---------------- |
| bun-websocket      | 620611.021552/s  |
| uwebsocket-js      | 560937.655412/s  |
| fasthttp-websocket | 531082.260734/s  |

## Contribution

### Start Server

using Docker Compose

```sh
docker compose up fasthttp-websocket
```

replace `fasthttp-websocket` with other framework

list of docker-compose server can check in `docker-compose.yaml` file

for `bun-websocket` is seperate test methods because bun don't support multiple websocket paths, so you need to run one by one.

### K6 benchmark

you need to [Install K6](https://k6.io/docs/get-started/installation/) on your local

```sh
npm run benchmark:all
```

replace `all` with specific test method

test methods list:

- `all`
- `connection`
- `plain-async`
- `plain-sync`
- `json-async`
- `json-sync`
- `binary-async`
- `binary-sync`
