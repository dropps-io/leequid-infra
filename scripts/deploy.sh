#!/bin/bash

# deploy app nginx -n dev --dry-run

CHART=${1}
APP=${2}
ARGS=${@:3}

helm upgrade --install nginx leequid-infra/charts/$CHART \
  -f leequid-infra/charts/values/dev/$APP.values.yaml \
  $ARGS

