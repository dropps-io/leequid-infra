ARG PRYSM_VERSION

FROM gcr.io/prysmaticlabs/prysm/beacon-chain:v$PRYSM_VERSION as prysm-beacon-chain
FROM gcr.io/prysmaticlabs/prysm/validator:v$PRYSM_VERSION as prysm-validator

FROM debian:bookworm-20231120-slim

COPY --from=prysm-beacon-chain /app/cmd/beacon-chain/beacon-chain /usr/local/bin
COPY --from=prysm-validator /app/cmd/validator/validator /usr/local/bin

ENTRYPOINT [ "beacon-chain" ]
