# Docker

Build `init.dockerfile` from root:
````shell
export GETH_VERSION=1.13.15
export PRYSM_VERSION=5.0.1
docker build -t europe-west1-docker.pkg.dev/leequid/leequid/init:geth${GETH_VERSION}-prysm${PRYSM_VERSION} \
  --build-arg GETH_VERSION --build-arg PRYSM_VERSION -f docker/init.dockerfile .
docker push europe-west1-docker.pkg.dev/leequid/leequid/init:geth${GETH_VERSION}-prysm${PRYSM_VERSION}
````

Build `prysm.dockerfile` from root:
````shell
export PRYSM_VERSION=5.0.1
docker build -t europe-west1-docker.pkg.dev/leequid/leequid/prysm:v${PRYSM_VERSION} \
  --build-arg PRYSM_VERSION -f docker/prysm.dockerfile .
docker push europe-west1-docker.pkg.dev/leequid/leequid/prysm:v${PRYSM_VERSION}
````
