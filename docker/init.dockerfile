# docker/init.dockerfile
ARG GETH_VERSION
ARG PRYSM_VERSION

# Define platform
FROM --platform=linux/amd64 ethereum/client-go:v${GETH_VERSION} as geth
FROM --platform=linux/amd64 prysmaticlabs/prysm-validator:v${PRYSM_VERSION} as prysm-validator

FROM --platform=linux/amd64 google/cloud-sdk:434.0.0-slim

COPY --from=prysm-validator /app/cmd/validator/validator /usr/local/bin
COPY --from=geth /usr/local/bin/geth /usr/local/bin
COPY scripts/lukso-key-gen-cli /usr/local/bin

RUN apt update && apt install dnsutils -y && rm -rf /var/lib/apt/lists/*
