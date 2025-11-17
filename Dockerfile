###################
# --- builder --- #
###################
FROM docker.io/rust:1.91-slim-trixie AS builder

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
ARG VERSION=stable2509-2
RUN git clone https://github.com/paritytech/polkadot-sdk.git -b polkadot-$VERSION --depth 1
WORKDIR /opt/polkadot-sdk
RUN cargo build --locked \
  --profile production \
  --bin polkadot \
  --bin polkadot-execute-worker \
  --bin polkadot-prepare-worker

##################
# --- runner --- #
##################
FROM docker.io/debian:13-slim

# Install curl for healthcheck
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 65532 nonroot \
  && useradd --system --uid 65532 --gid 65532 --create-home --home-dir /home/nonroot --shell /usr/bin/bash nonroot

COPY --from=builder /opt/polkadot-sdk/target/production/polkadot /usr/local/bin/polkadot
COPY --from=builder /opt/polkadot-sdk/target/production/polkadot-execute-worker /usr/local/bin/polkadot-execute-worker
COPY --from=builder /opt/polkadot-sdk/target/production/polkadot-prepare-worker /usr/local/bin/polkadot-prepare-worker

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
