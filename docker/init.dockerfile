ARG GETH_VERSION
ARG PRYSM_VERSION

FROM ethereum/client-go:v$GETH_VERSION as geth
FROM prysmaticlabs/prysm-validator:v$PRYSM_VERSION as prysm-validator

FROM google/cloud-sdk:434.0.0-slim

COPY --from=prysm-validator /app/cmd/validator/validator /usr/local/bin
COPY --from=geth /usr/local/bin/geth /usr/local/bin
COPY scripts/lukso-key-gen-cli /usr/local/bin

RUN apt update && apt install dnsutils -y  && rm -rf /var/lib/apt/lists/*
