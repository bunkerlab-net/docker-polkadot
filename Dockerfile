###################
# --- builder --- #
###################
FROM docker.io/rust:1.61 AS builder

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install \
        build-essential git clang \
        libclang-dev pkg-config libssl-dev cmake

WORKDIR /opt
ARG VERSION=0.9.24
RUN git clone https://github.com/paritytech/polkadot.git -b v$VERSION --depth 1
WORKDIR /opt/polkadot
RUN ./scripts/init.sh
RUN cargo build --release

##################
# --- runner --- #
##################
FROM docker.io/debian:11-slim

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tini && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt && \
    useradd -ms /bin/bash dot && \
    mkdir -p /home/dot/.local/share /data && \
    ln -s /data /home/dot/.local/share/polkadot && \
    chown -R dot:dot /home/dot/.local/share && \
    chown -R dot:dot /data

COPY --from=builder /opt/polkadot/target/release/polkadot /usr/local/bin/polkadot

USER dot
WORKDIR /home/dot
EXPOSE 30333 9933 9944
VOLUME /data

ENTRYPOINT [ "tini", "--", "/usr/local/bin/polkadot" ]
