#!/bin/bash

### example: deploy app nginx -n dev --dry-run

CHART=${1}
APP=${2}
ARGS=${@:3}

dir=~/projects/dropps/leequid-infra/charts

helm upgrade --install $APP $dir/$CHART \
  -f $dir/values/dev/$APP.values.yaml \
  $ARGS

