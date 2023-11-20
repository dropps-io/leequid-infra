# Docker

Build `init.dockerfile` from root:
````shell
GETH_VERSION=1.13.2
PRYSM_VERSION=4.0.8
docker build -t europe-west1-docker.pkg.dev/leequid/leequid/init:geth${GETH_VERSION}-prysm${PRYSM_VERSION} -f docker/init.dockerfile .
docker push europe-west1-docker.pkg.dev/leequid/leequid/init:geth${GETH_VERSION}-prysm${PRYSM_VERSION}
docker build -t europe-west1-docker.pkg.dev/leequid/leequid/init:latest -f docker/init.dockerfile .
````
