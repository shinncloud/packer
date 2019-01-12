FROM ubuntu:18.04

ARG PACKER_VERSION=1.3.1
ARG PACKER_VERSION_SHA256SUM=254cf648a638f7ebd37dc1b334abe940da30b30ac3465b6e0a9ad59829932fa3

RUN apt-get -y update && apt-get -y install ca-certificates && rm -rf /var/lib/apt/lists/*

COPY packer_${PACKER_VERSION}_linux_amd64.zip .
RUN echo "${PACKER_VERSION_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" > checksum && sha256sum -c checksum
RUN apt-get -y update && apt-get -y install unzip && /usr/bin/unzip packer_${PACKER_VERSION}_linux_amd64.zip

FROM ubuntu:18.04
RUN apt-get -y update && apt-get -y install ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=0 packer /usr/bin/packer
ENTRYPOINT ["/usr/bin/packer"]
