#!/bin/bash

### example: deploy app nginx -n dev --dry-run

ENV=dev

CHART=${1}
APP=${2}
ARGS=${@:3}

dir=leequid-infra/charts

kubectl config use-context gke_leequid_europe-west1-c_leequid-$ENV

helm upgrade -n main --install $APP $dir/$CHART \
  -f $dir/values/$ENV/$APP.values.yaml \
  $ARGS

