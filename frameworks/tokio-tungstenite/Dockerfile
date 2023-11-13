FROM rust:1.73-alpine3.17

WORKDIR /app

RUN apk add musl-dev

COPY . .

RUN cargo build --release

EXPOSE 9001

CMD ["./target/release/tokio-tungstenite-benchmark"]
