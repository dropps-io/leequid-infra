#!/bin/bash

# $LUKSO_KEY_GEN --language English new-mnemonic --num_validators 1 --mnemonic_language English --chain lukso --keystore_password password  --mnemonic_file seed.txt
# $LUKSO_KEY_GEN --language English existing-mnemonic --num_validators 1 --chain lukso  --validator_start_index 0 --keystore_password password --mnemonic="$(cat seed.txt)"

LUKSO_KEY_GEN=./lukso-key-gen-cli
KEYSTORE_SECRET=${KEYSTORE_SECRET:-"password"}
MNEMONIC_FILE=${MNEMONIC_FILE:-"seed.txt"}
VALIDATOR_PER_NODE=${VALIDATOR_PER_NODE:-1}
NODE_COUNT=${NODE_COUNT:-2}
NODE_PREFIX_NAME=${NODE_NAME:-"lukso"}
NETWORK=${NETWORK:-"mainnet"}
BUCKET=${BUCKET:-"leequid-prod-lukso"}
SECRET_PREFIX=${SECRET_PREFIX:-"prod"}

for (( i=0; i<$NODE_COUNT; i++ )); do
  NODE_NAME=${NODE_PREFIX_NAME}-${i}
  echo $NODE_NAME

  ### Generate seed and keystore
  $LUKSO_KEY_GEN  --language English new-mnemonic --mnemonic_language English --chain lukso \
      --num_validators $VALIDATOR_PER_NODE \
      --keystore_password $KEYSTORE_SECRET \
      --mnemonic_file $MNEMONIC_FILE

  ### Save mnemonic to Gcloud secret
  secret=${SECRET_PREFIX}-${NETWORK}-${NODE_NAME}-mnemonic
  gcloud secrets create $secret --data-file=$MNEMONIC_FILE

  ### Copy deposit json to /tmp
  cp validator_keys/deposit*.json /tmp/${NODE_NAME}-deposit.json

  ### Save Keystore to bucket
  #gsutil -m cp -r validator_keys/* gs://$BUCKET/$NETWORK/$NODE_NAME/keystores

  ### Clean folders
  rm -rf validator_keys/ $MNEMONIC_FILE
done

### Merge deposit wallet json
jq -s 'add' /tmp/*deposit.json > ${NODE_PREFIX_NAME}-deposit-data.json

### Save to bucket (gs://$BUCKET/$NETWORK/$NODE_NAME/${NODE_PREFIX_NAME}-deposit-data.json)

### Clean /tmp/*deposit.json
rm -f /tmp/*deposit.json


