FROM google/cloud-sdk:434.0.0-slim

COPY --from=prysmaticlabs/prysm-validator:v4.0.3 /app/cmd/validator/validator /usr/local/bin
COPY --from=ethereum/client-go:v1.11.6 /usr/local/bin/geth /usr/local/bin
COPY scripts/lukso-key-gen-cli /usr/local/bin
