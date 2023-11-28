FROM google/cloud-sdk:434.0.0-slim

COPY --from=prysmaticlabs/prysm-validator:v4.0.8 /app/cmd/validator/validator /usr/local/bin
COPY --from=ethereum/client-go:v1.13.2 /usr/local/bin/geth /usr/local/bin
COPY scripts/lukso-key-gen-cli /usr/local/bin

RUN apt update && apt install dnsutils -y  && rm -rf /var/lib/apt/lists/*
