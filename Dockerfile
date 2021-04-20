FROM rust:1.51 as builder

RUN USER=root cargo new --bin sbb
WORKDIR ./sbb
COPY ./Cargo.lock ./Cargo.toml ./
RUN cargo build --release
RUN rm src/*.rs
COPY ./src ./src
RUN rm ./target/release/deps/sbb*
RUN cargo build --release

FROM ubuntu:20.04

RUN apt update && apt install -y libssl-dev

COPY --from=builder /sbb/target/release/sbb .
EXPOSE 8080
ENTRYPOINT ["./sbb"]