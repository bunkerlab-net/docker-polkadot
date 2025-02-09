###################
# --- builder --- #
###################
FROM docker.io/rust:1.85-alpine AS builder

RUN apk add --update --no-cache \
      clang-dev \
      git \
      make \
      protoc

RUN rustup target add wasm32-unknown-unknown
RUN rustup component add rust-src

WORKDIR /opt
ARG VERSION=stable2412-2
RUN git clone https://github.com/paritytech/polkadot-sdk.git -b polkadot-$VERSION --depth 1
WORKDIR /opt/polkadot-sdk
RUN cargo build --locked --release \
  --bin polkadot \
  --bin polkadot-execute-worker \
  --bin polkadot-prepare-worker

##################
# --- runner --- #
##################
FROM docker.io/alpine:3 AS polkadot

# Install curl for healthcheck
RUN apk add --update --no-cache curl \
  && addgroup -g 65532 nonroot \
  && adduser -S -u 65532 -G nonroot -h /home/nonroot -s /bin/sh nonroot

COPY --from=builder /opt/polkadot-sdk/target/release/polkadot /usr/local/bin/polkadot
COPY --from=builder /opt/polkadot-sdk/target/release/polkadot-execute-worker /usr/local/bin/polkadot-execute-worker
COPY --from=builder /opt/polkadot-sdk/target/release/polkadot-prepare-worker /usr/local/bin/polkadot-prepare-worker

USER 65532

# P2P
EXPOSE 30333
# HTTP RPC
EXPOSE 9933
# WebSocket RPC
EXPOSE 9944
# Prometheus
EXPOSE 9615

VOLUME /data

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s \
    CMD curl -s -H "Content-Type: application/json" \
        -d '{"id":1, "jsonrpc":"2.0", "method":"system_health", "params":[]}' \
        http://localhost:9944

ENTRYPOINT [ "/usr/local/bin/polkadot" ]
