###################
# --- builder --- #
###################
FROM docker.io/rust:1.87-slim AS builder

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install \
      g++ \
      git \
      libclang-dev \
      make \
      protobuf-compiler

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
RUN rustup target add wasm32v1-none
# Keep `wasm32-unknown-unknown` and `rust-src` for LTS
# Will remove once `polkadot-sdk` backports
# https://github.com/paritytech/polkadot-sdk/pull/7008
RUN rustup target add wasm32-unknown-unknown
RUN rustup component add rust-src

WORKDIR /opt
ARG VERSION=stable2503-5
RUN git clone https://github.com/paritytech/polkadot-sdk.git -b polkadot-$VERSION --depth 1
WORKDIR /opt/polkadot-sdk
RUN cargo build --locked --release \
  --bin polkadot \
  --bin polkadot-execute-worker \
  --bin polkadot-prepare-worker

##################
# --- runner --- #
##################
FROM docker.io/debian:12-slim

# Install curl for healthcheck
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 65532 nonroot \
  && adduser --system --uid 65532 --gid 65532 --home /home/nonroot nonroot

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
