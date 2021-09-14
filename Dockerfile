FROM rust AS builder

ARG NAME=speedtest-rust
ARG TARGET=x86_64-unknown-linux-musl

# Use Rustup Nightly
RUN rustup default nightly; rustup update; rustup component add rust-src

# Download rust static linking tools
RUN rustup target add $TARGET
RUN set -eux; \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y musl-tools musl-dev upx && \
    update-ca-certificates

# Source code directory
WORKDIR /usr/src

# Install cargo tools
RUN cargo install cargo-strip exa

# Download and compile Rust dependencies
RUN cargo new $NAME
WORKDIR /usr/src/$NAME
COPY Cargo.toml .
RUN cargo build --release

# Build the executable from src/main.rs
COPY src ./src
RUN cargo build --release --target $TARGET

# Strip and Compress the binary
RUN cargo strip --target $TARGET
RUN upx --best --lzma /usr/src/$NAME/target/$TARGET/release/$NAME

# CMD [ "bash" ]


FROM scratch

ARG NAME=speedtest-rust
ARG TARGET=x86_64-unknown-linux-musl

ENV OH=YEAH

# Import CA certificate from builder.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Import executable our builder
COPY --from=builder /usr/src/$NAME/target/$TARGET/release/$NAME /

CMD ["/speedtest-rust", "--accept-license"]