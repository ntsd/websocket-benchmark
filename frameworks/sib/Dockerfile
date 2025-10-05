FROM rust:latest

ADD ./ /sib
WORKDIR /sib

RUN apt-get update && apt-get install -y cmake clang lld llvm libclang-dev
RUN cargo clean
RUN RUSTFLAGS="-C target-cpu=native" cargo build --release

EXPOSE 9001

CMD ["./target/release/sib-ws-bench"]