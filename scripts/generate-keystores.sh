#!/bin/bash

# $LUKSO_KEY_GEN --language English new-mnemonic --num_validators 1 --mnemonic_language English --chain lukso --keystore_password password  --mnemonic_file seed.txt
# $LUKSO_KEY_GEN --language English existing-mnemonic --num_validators 1 --chain lukso  --validator_start_index 0 --keystore_password password --mnemonic="$(cat seed.txt)"

LUKSO_KEY_GEN=./lukso-key-gen-cli
MNEMONIC_FILE=${MNEMONIC_FILE:-"seed.txt"}
VALIDATOR_PER_NODE=${VALIDATOR_PER_NODE:-2}
NODE_COUNT=${NODE_COUNT:-2}
NODE_PREFIX_NAME=${NODE_NAME:-"lukso"}
NETWORK=${NETWORK:-"mainnet"}
BUCKET=${BUCKET:-"leequid-prod-lukso"}
SECRET_PREFIX=${SECRET_PREFIX:-"prod"}

echo -e ">>> Get keystore secret from gcloud"
keystore_secret_id=${SECRET_PREFIX}-${NETWORK}-${NODE_PREFIX_NAME}-keystore-secret
KEYSTORE_SECRET=$(gcloud secrets versions access latest --secret="$keystore_secret_id")

echo -e "\n>>> Iterate over [node_count=$NODE_COUNT]"
for (( i=0; i<$NODE_COUNT; i++ )); do
  NODE_NAME=${NODE_PREFIX_NAME}-${i}
  echo -e "\n>>> Node Name [$NODE_NAME]"

  echo -e "\n>>> Run [$LUKSO_KEY_GEN] Generate keystore and mnemonic [num_validators=$VALIDATOR_PER_NODE]"
  $LUKSO_KEY_GEN  --language English new-mnemonic --mnemonic_language English --chain lukso \
      --num_validators $VALIDATOR_PER_NODE \
      --keystore_password $KEYSTORE_SECRET \
      --mnemonic_file $MNEMONIC_FILE

  secret=${SECRET_PREFIX}-${NETWORK}-${NODE_NAME}-mnemonic
  echo -e "\n>>> Save mnemonic file to gcloud secret [$secret]"
  gcloud secrets create $secret --data-file=$MNEMONIC_FILE

  echo -e "\n>>> Copy deposit to [/tmp/${NODE_NAME}-deposit.json]"
  cp validator_keys/deposit*.json /tmp/${NODE_NAME}-deposit.json

  echo -e "\n>>> Save keystores to [gs://$BUCKET/$NETWORK/$NODE_NAME/keystores]"
  gsutil -m cp -r validator_keys/* gs://$BUCKET/$NETWORK/$NODE_NAME/keystores

  rm -rf validator_keys/ $MNEMONIC_FILE
done

echo -e "\n>>> Merge all deposit wallet to [${NODE_PREFIX_NAME}-deposit-data.json]"
jq -s 'add' /tmp/*deposit.json > ${NODE_PREFIX_NAME}-deposit-data.json

echo -e "\n>>> Save deposit to [gs://$BUCKET/$NETWORK/${NODE_PREFIX_NAME}-deposit-data.json]"
gsutil -m cp ${NODE_PREFIX_NAME}-deposit-data.json gs://$BUCKET/$NETWORK/

rm -f /tmp/*deposit.json


