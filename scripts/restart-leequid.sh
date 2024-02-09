#!/bin/bash

### example: restart-leequid -i 0,3-5,12 # --> Restart leequid 0,3,4,5,12
### example: restart-leequid -A -v --> Restart all leequid with volumes
### example: restart-leequid -A -D --> Restart in dry-run mode all leequid

# Init vars
declare -a nodes
instance="leequid"

# Init option flags
index=()
env="dev"
namespace="main"
all=false
volume=false
dryRun=none

usage() {
  echo "Usage: $0 [-i <index>] [-e <dev|prod>] [-A <all>] [-v <include-volume>] [-D <dry-run>]"
  echo "Usage: $0 -i 0,2,4-6 (will restart leequid 0,2,4,5,6)" 1>&2; exit 1;
}

get_nodes_by_indexes() {
  string=$1
  nodes=()
  IFS=',;'
  read -ra list <<< "$string"

  for i in ${list[@]} ; do
    if [[ $i == *"-"* ]]; then
      start=$(echo $i | cut -d "-" -f1)
      end=$(echo $i | cut -d "-" -f2)
      for ((j=start; j<=end; j++)) ; do
         nodes+=("${instance}-$j")
      done
    else
      nodes+=("${instance}-$i")
    fi
  done
}

while getopts ":i:e:vAD" o; do
    case "${o}" in
        i)
            index=${OPTARG}
            ;;
        v)
            volume=true
            ;;
        e)
            env=${OPTARG}
            ;;
        A)
            all=true
            ;;
        D)
            dryRun="client"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if $all; then
  nodes=$(kubectl get po -n $namespace -l app.kubernetes.io/instance=${instance} --no-headers | awk '{print $1}')
elif [[ -n "$index" ]] ; then
  get_nodes_by_indexes ${index}
else
  echo "Index must be defined!"
  exit 1
fi

echo "These following pods will restart [volume=$volume] [dry-run=$dryRun]"
for node in ${nodes[@]} ; do
  echo "$node"
done

echo

while true; do
  read -p "Do you want to proceed? (y/n) " yn
  case $yn in
    [yY] ) echo;
      break;;
    [nN] ) echo exiting...;
      exit;;
    * ) echo invalid response;;
  esac
done

for node in ${nodes[@]} ; do
    echo "[$node] Restarting pod [volume=$volume]"
    if $volume; then
      kubectl -n $namespace delete pvc data-$node --wait=false --dry-run=$dryRun
    fi
    kubectl -n $namespace delete po $node --wait=true --dry-run=$dryRun
    kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/data-${node}
    kubectl wait --for=condition=Ready pod/${node}
    echo "[$node] Wait 10s"
    sleep 10
    echo "----"
done

echo "DONE"
