FROM ubuntu:22.04
#FROM google/cloud-sdk:434.0.0-slim

COPY --from=prysmaticlabs/prysm-validator:v4.0.3 /app/cmd/validator/validator /usr/local/bin
COPY --from=ethereum/client-go:v1.11.6 /usr/local/bin/geth /usr/local/bin
COPY scripts/lukso-key-gen-cli /usr/local/bin

RUN apt update && apt install -y apt-transport-https ca-certificates gnupg curl sudo \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && sudo apt update && sudo apt install -y google-cloud-cli && apt clean
