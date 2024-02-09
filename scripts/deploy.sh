#!/bin/bash

### example: deploy -c app -a nginx -e dev

# Init vars
stakingChart=("archive" "leequid")
appChart=("oracle" "orchestrator" "monitoring")
chart="app"

# Init option flags
env="dev"
dir="leequid-infra/charts"
namespace="main"
dryRun="false"

usage() {
  echo "Usage: $0 [-a <app>] [-e <dev|prod>] [-d <dir>] [-n <namespace>] [-D <dry-run>]" 1>&2; exit 1;
}

while getopts ":e:a:d:n:D" o; do
    case "${o}" in
        e)
            env=${OPTARG}
            #((env == "dev" || env == "prod")) || usage
            ;;
        a)
            app=${OPTARG}
            ;;
        d)
            dir=${OPTARG}
            ;;
        n)
            namespace=${OPTARG}
            ;;
        D)
            dryRun="server"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "$app" ]]; then
    echo "Option -a (app) must be defined."
    usage
    exit 1
fi

if [[ "${stakingChart[*]}" =~ "$app" ]]; then
  chart="staking"
elif [[ ! "${appChart[*]}" =~ "$app" ]] ; then
  echo "This app [$app] does not exist!"
  exit 1
fi

kubectl config use-context gke_leequid_europe-west1-c_leequid-$env

helm upgrade -n $namespace --install $app $dir/$chart -f $dir/values/$env/$app.values.yaml --dry-run=$dryRun
